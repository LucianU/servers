{ config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/tw-knowledge-store-v2.nix
    ../../modules/tw-haskell-v2.nix
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
      tw_knowledge_store_v2_restic_pass = {};
      tw_haskell_v2_restic_pass = {};
      digitalocean_spaces_credentials = {};
    };
  };

  services = {
    openssh.enable = true;

    tw-knowledge-store-v2 = {
      enable = true;
      port = 8080;
      domainName = "know.elbear.com";
      backupCloudCredentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
      backupRepo = "s3:fra1.digitaloceanspaces.com/know-elbear-com";
      backupPasswordFile = config.sops.secrets.tw_knowledge_store_v2_restic_pass.path;
    };

    tw-haskell-v2 = {
      enable = true;
      port = 8081;
      domainName = "haskell.elbear.com";
      backupCloudCredentialsFile = config.sops.secrets.digitalocean_spaces_credentials.path;
      backupRepo = "s3:fra1.digitaloceanspaces.com/haskell-elbear-com";
      backupPasswordFile = config.sops.secrets.tw_haskell_v2_restic_pass.path;
    };
  };

	nixpkgs.system = "x86_64-linux";
	system.stateVersion = "23.05";
  documentation.nixos.enable = false;
}
