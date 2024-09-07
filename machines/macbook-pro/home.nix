{ config, pkgs, lib, ... }:
let
  homeDir = config.home.homeDirectory;
in
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
      git
      fd
      ripgrep
      colordiff
      bat
      restic
      wireguard-tools
      transmission
      eza

      # Rust
      cargo

      # Formal Verification
      alloy6

      # Nix tooling
      nixos-rebuild
      cachix

      # JS
      bun

      # Docker
      colima
      docker

      # secrets
      age
      sops
    ];

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      LANG = "en_US.UTF-8";
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_REPOSITORY = "/opt/homebrew";
      SOPS_AGE_KEY_FILE = "${homeDir}/.config/sops/age/keys.txt";
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
    };

    bash = {
      enable = true;
      shellAliases = {
        ll = "eza -a1l --color=always -I *.DS_Store";
        neovim = "/opt/homebrew/bin/nvim -u ~/.config/neovim/init.lua";
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        warn_timeout = "10m";
      };
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
        core.excludesFile = "${homeDir}/.config/git/ignore";
        pull.rebase = false;
      };

      ignores =  [
        ".DS_Store"
      ];
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
