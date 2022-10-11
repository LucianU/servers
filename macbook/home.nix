{ config, pkgs, lib, ... }:

{
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
      ripgrep
      vagrant
    ];

    sessionVariables = {
      EDITOR = "nvim";    
      VISUAL = "nvim";
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_REPOSITORY = "/opt/homebrew";
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
    zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -al";
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
    };
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-nix
        direnv-vim
      ];
      extraConfig = "lua << EOF\n" + builtins.readFile ./neovim-settings.lua + "\nEOF";
    };
    starship = {
      enable = true;
    };
    irssi = {
      enable = true;
    };
  };
}
