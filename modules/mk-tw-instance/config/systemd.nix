{ service-name, service-description, cfg, lib, pkgs }:

with lib;

let
  service_config =
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

          snapshots=$(RESTIC_REPOSITORY="${repo}" RESTIC_PASSWORD_FILE=${passwordFile} ${pkgs.restic}/bin/restic snapshots --quiet)

          if [[ -z "$snapshots" ]]; then
            echo "No snapshots found. Exiting..."
            exit 0
          else
            RESTIC_REPOSITORY="${repo}" \
            RESTIC_PASSWORD_FILE=${passwordFile} \
            ${pkgs.restic}/bin/restic restore latest --target /tmp/${service-name}-backup/

            TIDDLERS_PATH="$(find /tmp/${service-name}-backup/ -type d -name tiddlers)"

            mv "$TIDDLERS_PATH" "${cfg.dataDir}/tiddlers"
          fi
        fi
      '';

      tiddlywiki = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
      port = "port=${toString cfg.port}";
      credentials = "credentials=${cfg.users}";
      readers = "readers=${cfg.read_access}";
      writers = "writers=${cfg.write_access}";
    in
      {
        description = service-description;
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          User = "root";
          ExecStartPre = load-data-if-new-deploy;
          ExecStart = "${tiddlywiki} ${cfg.dataDir} --listen ${port} ${credentials} ${readers} ${writers}";
        };
      };
in
  {
    tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root - -"
      "L+ ${cfg.dataDir}/tiddlywiki.info - - - - ${cfg.package}/tiddlywiki.info"
    ];

    services.${service-name} = service_config;
  }
