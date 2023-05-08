{ config, pkgs, lib, inputs, ... }:
{
  boot = {
    cleanTmpDir = true;

    initrd = {
      availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
      kernelModules = [ "nvme" ];
    };

    loader = {
      grub = {
        device = "/dev/sda";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
  };

  zramSwap.enable = true;

  networking = {
    hostName = "hetzner-nixos-main";
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
    defaultSopsFile = ../secrets/hetzner-main.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = { };
  };

  services = {
    openssh.enable = true;
  };

  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "22.11";
  documentation.nixos.enable = false;
}
