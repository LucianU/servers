{ service-name, service-pkg, service-description, cfg, lib }:

with lib;

let
  enable = mkEnableOption service-description;

  package = mkOption {
    type = types.package;
    default = service-pkg;
    description = "The package to use for the TiddlyWiki instance.";
  };

  dataDir = mkOption {
    type = types.path;
    default = "/var/lib/${service-name}";
    description = "The directory where the TiddlyWiki instance will be stored.";
  };

  port = mkOption {
    type = types.port;
    default = null;
    description = "The port on which the TiddlyWiki instance will listen.";
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
in
  {
    enable = enable;
    package = package;
    dataDir = dataDir;
    port = port;
    domainName = domainName;
    backup = backup;
    restore = restore;
    listenOptions = listenOptions;
  }
