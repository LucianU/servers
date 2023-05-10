{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.tw-rust-v2;
  tw-rust-pkg = inputs.wikis.packages.${config.nixpkgs.system}.rust;
  description = "Rust - TiddlyWiki instance";
  service-name = "tw-rust-v2";
in {

  options.services.tw-sim = {
    enable = mkEnableOption description;

    package = mkOption {
      type = types.package;
      default = tw-rust-pkg;
      description = "The package to use for the TiddlyWiki instance.";
    };

    port = mkOption {
      type = types.int;
      default = null;
      description = "The port on which the TiddlyWiki instance will listen.";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/${service-name}";
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
        credentials="${cfg.dataDir}/users.csv";
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
        "L ${cfg.dataDir}/tiddlywiki.info - - - - ${cfg.package}/tiddlywiki.info"
        "L ${cfg.dataDir}/users.csv - - - - ${cfg.package}/users.csv"
      ];

      services."${service-name}" =
      let
        restic-for-service = pkgs.writeShellScript "restic-${service-name}" ''
          source ${cfg.backupCloudCredentialsFile}

          ${pkgs.restic}/bin/restic -r ${cfg.backupRepo} -p ${cfg.backupPasswordFile} "$@"
        '';
        restore-data = pkgs.writeShellScript "restore-data-for-${service-name}.sh" ''
          set -euo pipefail

          if [ ! -d "${cfg.dataDir}/tiddlers" ]; then
            ${restic-for-service} restore latest --target /tmp/${service-name}-backup/

            TIDDLERS_FULL_PATH="$(find /tmp/${service-name}-backup/ -type d -name tiddlers)"

            mv "$TIDDLERS_FULL_PATH" "${cfg.dataDir}/tiddlers"
          fi
        '';
        tiddlywiki = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
        listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
      in
        {
          description = description;
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            User = "root";
            ExecStartPre = restore-data;
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
        "${service-name}" = {
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
