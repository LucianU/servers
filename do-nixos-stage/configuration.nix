{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../services/tiddlywiki-staging.nix
  ];

  boot = {
    growPartition = true;
    kernelParams = [ "console=ttyS0" "panic=1" "boot.panic_on_fail" ];
    initrd.kernelModules = [ "virtio_scsi" ];
    kernelModules = [ "virtio_pci" "virtio_net" ];
    loader = {
      grub.device = "/dev/vda";
      timeout = 0;
      grub.configurationLimit = 0;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      autoResize = true;
      fsType = "ext4";
    };
  };

  networking = {
    hostName = "do-nixos-stage";
    firewall.allowedTCPPorts = [ 80 443 ];
  };

  users = {
    users = {
      root.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPI+dFnzXZ0xACwp1x9hMH0FFx4+WLj7ZiXW+j2z58sc lucian@Lucians-MacBook-Pro-2.local"
      ];
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "lucian.ursu@gmail.com";
  };

  sops = {
    defaultSopsFile = ../secrets/do-nixos-stage.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      restic_pass = {};
      digitalocean_spaces_credentials = {};
    };
  };

  services = {
    openssh.enable = true;
    do-agent.enable = true;
  };

  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "22.11";
  documentation.nixos.enable = false;
}
