{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.knowledge-store;
  listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
  exe = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
  knowledge-store-pkg = inputs.knowledge-store;
in {

  options.services.knowledge-store = {

    enable = mkEnableOption "Knowledge Store - TiddlyWiki instance";
    package = mkOption {
      type = types.package;
      default = knowledge-store-pkg;
    };
    port = mkOption {
      type = types.int;
      default = null;
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/knowledge-store";
    };

    listenOptions = mkOption {
      type = types.attrs;
      default = {
        credentials="${cfg.package}/users.csv";
        readers="(authenticated)";
        writers="(authenticated)";
      };
      example = {
        credentials = "../credentials.csv";
        readers="(authenticated)";
        port = 3456;
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
      ];

      services.knowledge-store = {
        description = "Knowledge Store - TiddlyWiki instance";
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
