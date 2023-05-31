{ service-name, service-description, cfg, lib, pkgs }:

with lib;

let
  systemd = import ./systemd.nix { inherit service-name service-description cfg lib pkgs; };
  nginx = import ./nginx.nix { inherit cfg; };
  restic_backups = import ./restic-backups.nix { inherit service-name cfg; };
in
  mkIf cfg.enable {
    systemd = systemd;

    services = {
      nginx = nginx;
      restic.backups = restic_backups;
    };
  }
