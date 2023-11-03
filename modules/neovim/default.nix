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

        nvim-treesitter
        nvim-treesitter-parsers.haskell

        nvim-tree-lua
        bufferline-nvim

        fzf-vim
        fzf-lsp-nvim
        ultisnips

        plenary-nvim
        telescope-nvim
        haskell-tools-nvim

        # theme
        solarized
      ];
      extraConfig = "lua << EOF\n" + builtins.readFile ./neovim-settings.lua + "\nEOF";
    };
  };
}
