{ service-name, cfg }:
{
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
}
