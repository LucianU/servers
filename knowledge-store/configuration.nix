{ config, pkgs, lib, inputs, ... }:
let
  vars = import ./modules/vars.nix;
in
  {
    imports = [
      ./hardware-configuration.nix
      ./networking.nix # generated at runtime by nixos-infect

      ./modules/services/know-elbear-com.nix
      ./modules/services/haskell-elbear-com.nix
      ./modules/services/rust-elbear-com.nix
      ./modules/services/publish-elbear-com.nix
      ./modules/services/sim-elbear-com.nix
    ];

    nixpkgs.system = "x86_64-linux";
    system.stateVersion = "22.11";

    boot.cleanTmpDir = true;

    networking.hostName = "knowledge-store";
    networking.firewall.allowPing = true;
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "lucian.ursu@gmail.com";
    };

    sops = {
      defaultSopsFile = ./secrets/secrets.yaml;
      age.keyFile = "${inputs.age-keys}/keys.txt";
      secrets = {
        restic_pass = {};
        digital_ocean_credentials = {};
        aws_access_key_id = {};
        aws_secret_access_key = {};
      };
    };

    users.users.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1tiiUHIsJo2jlbpIz9pIubI9EPgyvdwiNmiZ6uDk9p3ut/OHWJYNGOqCMQkkohZPEdIXqipbWj8u3BAGr1quHKlPj+dJ+cB6OOqQdra9lpE6ZW1c7ezAqE7e1JPo5ad1VBEy7LNrCNNPMpT1W31TIuy5f+iHerSReCfI0SMOXFQm2UNnO0uN6YYShCezF5M+4QceEqBZdtzp0tnC24e4gnhe9iwulJQVIU/MzXIYWwUoEhdFuF8X8fkyHiJ2N+h85bj8fH7L1Iq+ocDrh4JeNqcq3gOsDOE8YjA+SL840x2ktFSkh1YLefyLbTOmqi2tJ8N5vbHm0idrgX1Y8KmJx lucian.ursu@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUpTfiSxp7qyj4AahqY1navyqobYRfuocP+bF4epF79 created for nixbuild"
    ];
    users.users = {
      tiddlywiki = {
        group = "tiddlywiki";
        isSystemUser = true;
      };
    };
    users.groups.tiddlywiki = {};

    documentation.nixos.enable = false;

    services.openssh.enable = true;

    services.wordpress.sites = {
      "hangout.elbear.com" = {
        virtualHost = {
        };
      };
    };
    services.wordpress.webserver = "nginx";

    services.knowledge-store = {
      enable = true;
      port = vars.knowPort;
    };

    services.haskell = {
      enable = true;
      port = vars.haskellPort;
    };

    services.rust = {
      enable = true;
      port = vars.rustPort;
    };

    services.public-wiki = {
      enable = true;
      port = vars.publishPort;
    };

    services.sim-wiki = {
      enable = true;
      port = vars.simPort;
    };

    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts = let
        common = locations: {
          enableACME = true;
          forceSSL = true;

          inherit locations;
        };

        proxy = port:
          common {
            "/" = {
              proxyPass = "http://127.0.0.1:" + toString(port) + "/";
              extraConfig = ''
                proxy_set_header        Host             $host;
                proxy_set_header        X-Real-IP        $remote_addr;
                proxy_set_header        X-Forwarded-For  $proxy_add_x_forwarded_for;
              '';
            };
          };
        in
          {
            "know.elbear.com" = proxy vars.knowPort;
            "haskell.elbear.com" = proxy vars.haskellPort;
            "rust.elbear.com" = proxy vars.rustPort;
            "publish.elbear.com" = proxy vars.publishPort;
            "sim.elbear.com" = proxy vars.simPort;
            "hangout.elbear.com" = {
              enableACME = true;
              forceSSL = true;
            };
          };
    };

    services.restic.backups = {
      remotebackup = {
        # In this case, the repo already exists. Otherwise, we would set it to true;
        initialize = false;
        paths = [
          config.services.knowledge-store.dataDir
          config.services.haskell.dataDir
          config.services.rust.dataDir
          config.services.sim-wiki.dataDir
        ];
        repository = vars.digitalOceanSpace;
        passwordFile = config.sops.secrets.restic_pass.path;
        environmentFile = config.sops.secrets.digital_ocean_credentials.path;
        timerConfig = {
          OnCalendar = "*:00";
        };
        pruneOpts = [
          "--keep-hourly 24"
          "--keep-daily 7"
        ];
      };
    };
  }
