{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ../../modules/tw-knowledge-store-v2.nix
    ../../modules/tw-haskell-v2.nix
    ../../modules/tw-rust-v2.nix
    ../../modules/tw-sim.nix
    ../../modules/tw-publish.nix
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
    defaultSopsFile = ../../secrets/do-nixos-stage.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      tw_stage_restic_pass = {};
      tw_knowledge_store_restic_pass = {};
      tw_haskell_restic_pass = {};
      tw_rust_restic_pass = {};
      tw_sim_restic_pass = {};
      digitalocean_spaces_credentials = {};
    };
  };

  services = {
    openssh.enable = true;
    do-agent.enable = true;

    tw-knowledge-store-v2 = {
      enable = true;
      port = 8080;
      domainName = "know.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/know-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_knowledge_store_restic_pass.path;
      };
    };

    tw-haskell-v2 = {
      enable = true;
      port = 8081;
      domainName = "haskell.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/haskell-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_haskell_restic_pass.path;
      };
    };

    tw-rust-v2 = {
      enable = true;
      port = 8082;
      domainName = "rust.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/rust-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_rust_restic_pass.path;
      };
    };

    tw-sim = {
      enable = true;
      port = 8083;
      domainName = "sim.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/sim-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_sim_restic_pass.path;
      };
    };

    tw-publish = {
      enable = true;
      port = 8084;
      domainName = "publish.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:fra1.digitaloceanspaces.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };
    };
  };

  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "22.11";
  documentation.nixos.enable = false;
}
