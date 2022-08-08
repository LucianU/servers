{ config, pkgs, lib, ... }:

{
  home.stateVersion = "22.05";

  home.username = "lucian";
  home.homeDirectory = "/Users/lucian";

  home.packages = with pkgs; [
    coreutils
    curl
    wget
    jq
    cachix
    git
    ripgrep
    vagrant
  ];
  home.sessionVariables = {
    EDITOR = "nvim";    
    VISUAL = "nvim";
    HOMEBREW_PREFIX = "/opt/homebrew";
    HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
    HOMEBREW_REPOSITORY = "/opt/homebrew";
  };
  home.sessionPath = [
    "/nix/var/nix/profiles/default/bin"
    "/opt/homebrew/bin"
  ];

  nix.enable = true;

  programs.home-manager = {
    enable = true;
    path = "${config.home.homeDirectory}/.config/nixpkgs/home.nix";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -al";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.htop = {
    enable = true;
    settings.show_program_path = true;
  };

  programs.git = {
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

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      vim-nix
      direnv-vim
    ];
    extraConfig = builtins.readFile ./neovim-settings.lua;
  };

  programs.starship = {
    enable = true;
  };

  programs.irssi = {
    enable = true;
  };
}
