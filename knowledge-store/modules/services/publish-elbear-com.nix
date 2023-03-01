{ config, lib, pkgs, inputs, ... }:

with lib;

let
  cfg = config.services.public-wiki;
  listenParams = concatStrings (mapAttrsToList (n: v: " '${n}=${toString v}' ") cfg.listenOptions);
  exe = "${pkgs.nodePackages.tiddlywiki}/lib/node_modules/.bin/tiddlywiki";
  public-wiki-pkg = inputs.wikis.packages.${config.nixpkgs.system}.publish;
in {

  options.services.public-wiki = {

    enable = mkEnableOption "Public Wiki - TiddlyWiki instance";
    package = mkOption {
      type = types.package;
      default = public-wiki-pkg;
    };
    port = mkOption {
      type = types.int;
      default = null;
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/public-wiki";
    };

    listenOptions = mkOption {
      type = types.attrs;
      default = {
        credentials="${cfg.package}/users.csv";
        readers="(anon)";
        writers="(authenticated)";
      };
      example = {
        credentials = "../credentials.csv";
        readers="(authenticated)";
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
        "L ${cfg.dataDir}/plugins - - - - ${cfg.package}/plugins"
      ];

      services.public-wiki = {
        description = "Public Wiki - TiddlyWiki instance";
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
