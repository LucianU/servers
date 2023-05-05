{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.tw-knowledge-store-v2;
  knowledge-store-pkg = inputs.knowledge-store;
  description = "Knowledge Store - TiddlyWiki Instance";
in {

  options.services.tw-knowledge-store-v2 = {

    enable = mkEnableOption description;

    package = mkOption {
      type = types.package;
      default = knowledge-store-pkg;
      description = "The package to use for the TiddlyWiki instance.";
    };

    port = mkOption {
      type = types.int;
      default = null;
      description = "The port on which the TiddlyWiki instance will listen.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/knowledge-store-v2";
      description = "The directory where the TiddlyWiki instance will be stored.";
    };

    domainName = mkOption {
      type = types.str;
      default = null;
      description = "The domain name of the TiddlyWiki instance.";
    };

    backupRepo = mkOption {
      type = types.str;
      default = null;
      description = "The URL of the Cloud Object Storage bucket where backups will be stored.";
    };

    backupPasswordFile = mkOption {
      type = types.path;
      default = null;
      description = "The file that contains the password used to encrypt backups.";
    };

    backupCloudCredentialsFile = mkOption {
      type = types.path;
      default = null;
      description = "The file that contains the credentials used to access the Cloud Object Storage bucket.";
    };

    listenOptions = mkOption {
      type = types.attrs;

      default = {
        credentials="${cfg.package}/wiki/users.csv";
        readers="(authenticated)";
        writers="(authenticated)";
      };

      example = {
        credentials = "../credentials.csv";
        readers="(anon)";
        writers="(authenticated)";
      };

      description = ''
        Parameters passed to <literal>--listen</literal> command.
        Refer to <link xlink:href="https://tiddlywiki.com/#WebServer"/>
        for details on supported values.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 root root - -"
        "L ${cfg.dataDir}/tiddlywiki.info - - - - ${cfg.package}/wiki/tiddlywiki.info"
      ];

      services.tw-knowledge-store-v2 =
      let
        listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
        tiddlywiki = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
      in
        {
          description = description;
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            User = "root";
            ExecStart = "${tiddlywiki} ${cfg.dataDir} --listen port=${toString(cfg.port)} ${listenParams}";
          };
        };
    };

		services = {
      nginx = {
        enable = true;
        virtualHosts = {
          "${cfg.domainName}" = {
            forceSSL = true;
            enableACME = true;

            locations = {
              "/" = {
                proxyPass = "http://127.0.0.1:" + toString(cfg.port) + "/";
                extraConfig = ''
                  proxy_set_header        Host             $host;
                  proxy_set_header        X-Real-IP        $remote_addr;
                  proxy_set_header        X-Forwarded-For  $proxy_add_x_forwarded_for;
                '';
              };
            };
          };
        };
      };

      restic.backups = {
        tw-knowledge-store-v2 = {
          initialize = false;
          paths = [
            "${cfg.dataDir}/tiddlers"
          ];

          repository = cfg.backupRepo;
          passwordFile = cfg.backupPasswordFile;
          environmentFile = cfg.backupCloudCredentialsFile;

          timerConfig = {
            OnCalendar = "*:00";
          };

          pruneOpts = [
            "--keep-hourly 24"
            "--keep-daily 7"
          ];
        };
      };
    };
  };
}
