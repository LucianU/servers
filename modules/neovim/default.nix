{ config, pkgs, lib, ... }:

{
  imports = [
    ./plugins/copilot-vim
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim

        vim-nix
        direnv-vim

        vim-terraform
        vim-terraform-completion

        nvim-tree-lua
        bufferline-nvim

        fzf-vim
        fzf-lsp-nvim
        ultisnips

        # theme
        solarized

        # paid services
        # copilot-vim
      ];
      extraConfig = "lua << EOF\n" + builtins.readFile ./neovim-settings.lua + "\nEOF";
    };
  };
}
