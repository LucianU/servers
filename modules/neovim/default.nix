{ config, pkgs, lib, ... }:

{
  imports = [
  ];

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;

      plugins = with pkgs.vimPlugins; [
        editorconfig-nvim

        direnv-vim

        vim-terraform
        vim-terraform-completion

        nvim-treesitter

        nvim-treesitter-parsers.nix
        vim-nix

        nvim-tree-lua
        bufferline-nvim

        fzf-vim
        fzf-lsp-nvim
        ultisnips

        plenary-nvim
        telescope-nvim

        haskell-tools-nvim
        nvim-treesitter-parsers.haskell

        # theme
        solarized
      ];
      extraConfig = "lua << EOF\n" + builtins.readFile ./neovim-settings.lua + "\nEOF";
    };
  };
}
