{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/tw-knowledge-store.nix
    ../../modules/tw-haskell.nix
    ../../modules/tw-rust.nix
    ../../modules/tw-publish.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;


  networking = {
    hostName = "oci-main";
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
    defaultSopsFile = ../../secrets/oci-main.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      tw_stage_restic_pass = {};
      tw_knowledge_store_restic_pass = {};
      tw_haskell_restic_pass = {};
      tw_rust_restic_pass = {};
      tw_stage_users = {};
      cloudflare_r2_credentials = {};
    };
  };

  services = {
    openssh.enable = true;

    tw-knowledge-store = {
      enable = true;
      port = 8080;
      domainName = "know.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/know-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_knowledge_store_restic_pass.path;
      };

      users = config.sops.secrets.tw_stage_users.path;
      read_access = "(authenticated)";
      write_access = "(authenticated)";
    };

    tw-haskell = {
      enable = true;
      port = 8081;
      domainName = "haskell.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/haskell-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_haskell_restic_pass.path;
      };

      users = config.sops.secrets.tw_stage_users.path;
      read_access = "(anon)";
      write_access = "(authenticated)";
    };

    tw-rust = {
      enable = true;
      port = 8082;
      domainName = "rust.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/rust-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_rust_restic_pass.path;
      };

      users = config.sops.secrets.tw_stage_users.path;
      read_access = "(anon)";
      write_access = "(authenticated)";
    };

    tw-publish = {
      enable = true;
      port = 8084;
      domainName = "publish.staging.elbear.com";

      backup = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      restore = {
        backend = {
          url = "s3:9997ad20d4c639d7d9b6e7293936ee5b.r2.cloudflarestorage.com/stage-elbear-com";
          credentialsFile = config.sops.secrets.cloudflare_r2_credentials.path;
        };
        passwordFile = config.sops.secrets.tw_stage_restic_pass.path;
      };

      users = config.sops.secrets.tw_stage_users.path;
      read_access = "(anon)";
      write_access = "(authenticated)";
    };
  };

  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "22.11";
  documentation.nixos.enable = false;
}
