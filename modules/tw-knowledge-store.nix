{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.tw-knowledge-store;
  listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
  exe = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
  knowledge-store-pkg = inputs.knowledge-store;
  description = "Knowledge Store - TiddlyWiki Instance";
in {

  options.services.tw-knowledge-store = {

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
      default = "/var/lib/knowledge-store";
      description = "The directory where the TiddlyWiki instance will be stored.";
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

      services.tw-knowledge-store = {
        description = description;
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "on-failure";
          User = "root";
          ExecStart = "${exe} ${cfg.dataDir} --listen port=${toString(cfg.port)} ${listenParams}";
        };
      };
    };
  };
}
