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

  users = mkOption {
    type = types.path;
    default = null;
    description = "A file with users and their passwords in csv format.";
  };

  read_access = mkOption {
    type = types.enum [ "(anon)" "(authenticated)" ];
    default = "(authenticated)";
    description = "The type of read access to the TiddlyWiki instance.";
  };

  write_access = mkOption {
    type = types.enum [ "(anon)" "(authenticated)" ];
    default = "(authenticated)";
    description = "The type of write access to the TiddlyWiki instance.";
  };
in
  {
    enable = enable;
    package = package;
    dataDir = dataDir;
    backup = backup;
    restore = restore;
    port = port;
    domainName = domainName;
    users = users;
    read_access = read_access;
    write_access = write_access;
  }
