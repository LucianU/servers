{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/neovim
  ];

  home = {
    stateVersion = "22.05";

    username = "lucian";
    homeDirectory = "/Users/lucian";

    packages = with pkgs; [
      coreutils
      curl
      wget
      jq
      cachix
      git
      fd
      ripgrep
      colordiff
      bat
      restic
      wireguard-tools
      transmission
      eza
      nil

      # Haskell tooling
      haskell-language-server

      haskellPackages.fast-tags
      haskellPackages.hoogle
      haskellPackages.haskell-debug-adapter
      haskellPackages.ghci-dap

      colima # Docker runtime
      docker
      terraform

      # deployment
      nixos-rebuild

      # secrets
      age
      sops
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_REPOSITORY = "/opt/homebrew";
      SOPS_AGE_KEY_FILE = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
    sessionPath = [
      "/etc/profiles/per-user/lucian/bin"
      "/run/current-system/sw/bin"
      "/opt/homebrew/bin"
    ];
  };

  nix.enable = true;

  programs = {
    home-manager = {
      enable = true;
      path = "${config.home.homeDirectory}/.config/nixpkgs/home.nix";
    };

    bash = {
      enable = true;
      shellAliases = {
        ll = "eza -a1l --color=always";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    htop = {
      enable = true;
      settings.show_program_path = true;
    };

    git = {
      enable = true;
      userName = "Lucian Ursu";
      userEmail = "lucian.ursu@gmail.com";
      delta = {
        enable = true;
        options = {
          side-by-side = true;
          line-numbers = true;
        };
      };

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        pull.rebase = false;
      };
    };

    starship = {
      enable = true;
      settings = {
        command_timeout = 1000;
      };
    };

    irssi = {
      enable = true;
      networks = {
        liberachat = {
          nick = "elbear";
          server = {
            address = "irc.libera.chat";
            port = 6697;
            autoConnect = true;
            ssl.enable = true;
          };
          channels = {
            haskell.autoJoin = true;
            nixos.autoJoin = true;
            python.autoJoin = true;
          };
        };
      };
      aliases = {
        ID = "msg nickserv identify";
      };
    };
  };
}
