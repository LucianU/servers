{ service-name, service-pkg, config, lib, pkgs, ... }:

with lib;

let
  description = "${service-name} - Tiddlywiki instance";
  cfg = config.services.${service-name};
in
  let
    options =  {

      enable = mkEnableOption description;

      package = mkOption {
        type = types.package;
        default = service-pkg;
        description = "The package to use for the TiddlyWiki instance.";
      };

      port = mkOption {
        type = types.port;
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

      backup = {
        backend = {
          url = mkOption {
            type = types.str;
            default = null;
            description = "The URL of the Cloud Object Storage bucket where backups will be stored.";
          };

          credentialsFile = mkOption {
            type = types.path;
            default = null;
            description = "The file that contains the credentials used to access the Cloud Object Storage bucket.";
          };
        };

        passwordFile = mkOption {
          type = types.path;
          default = null;
          description = "The file that contains the password used to encrypt backups.";
        };
      };

      restore = {
        backend = {
          url = mkOption {
            type = types.str;
            default = cfg.backup.backend.url;
            description = "The URL of the Cloud Object Storage bucket where backups are stored.";
          };

          credentialsFile = mkOption {
            type = types.path;
            default = cfg.backup.backend.credentialsFile;
            description = "The file that contains the credentials used to access the Cloud Object Storage bucket.";
          };
        };

        passwordFile = mkOption {
          type = types.path;
          default = cfg.backup.passwordFile;
          description = "The file that contains the password used to encrypt backups.";
        };
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

    config_systemd = {
      tmpfiles.rules = [
        "d ${cfg.dataDir} 0755 root root - -"
        "L+ ${cfg.dataDir}/tiddlywiki.info - - - - ${cfg.package}/tiddlywiki.info"
        "L+ ${cfg.dataDir}/users.csv - - - - ${cfg.package}/users.csv"
      ];

      services.${service-name} =
        let
          repo = cfg.restore.backend.url;
          repoCredentialsFile = cfg.restore.backend.credentialsFile;
          passwordFile = cfg.restore.passwordFile;

          load-data-if-new-deploy = pkgs.writeShellScript "load-data-if-new-deploy-of-${service-name}.sh" ''
            set -euo pipefail

            if [ ! -d "${cfg.dataDir}/tiddlers" ]; then
              source ${repoCredentialsFile}

              # without the explicit `export`, restic doesn't "see" the variables
              export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

              RESTIC_REPOSITORY="${repo}" \
              RESTIC_PASSWORD_FILE=${passwordFile} \
              ${pkgs.restic}/bin/restic restore latest --target /tmp/${service-name}-backup/

              TIDDLERS_PATH="$(find /tmp/${service-name}-backup/ -type d -name tiddlers)"

              mv "$TIDDLERS_PATH" "${cfg.dataDir}/tiddlers"
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
              ExecStartPre = load-data-if-new-deploy;
              ExecStart = "${tiddlywiki} ${cfg.dataDir} --listen port=${toString(cfg.port)} ${listenParams}";
            };
          };
    };

    config_services_nginx = {
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

    config_services_restic_backups = {
      ${service-name} = {
        initialize = false;
        paths = [
          "${cfg.dataDir}/tiddlers"
        ];

        repository = cfg.backup.backend.url;
        passwordFile = cfg.backup.passwordFile;
        environmentFile = cfg.backup.backend.credentialsFile;

        timerConfig = {
          OnCalendar = "*:00";
        };

        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
        ];
      };
    };

  in
    {

      options = {
        services = {
          ${service-name} = options;
        };
      };

      config = mkIf cfg.enable {
        systemd = config_systemd;

        services = {
          nginx = config_services_nginx;
          restic.backups = config_services_restic_backups;
        };
      };
    }
