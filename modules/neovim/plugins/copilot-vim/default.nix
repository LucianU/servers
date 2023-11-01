{ config, pkgs, lib, ... }:
let
  inherit (pkgs) fetchFromGitHub;
  inherit (pkgs.vimUtils) buildVimPluginFrom2Nix;

  copilot-vim = buildVimPluginFrom2Nix {
    pname = "copilot.vim";
    version = "1.8.3";

    src = fetchFromGitHub {
      owner = "github";
      repo = "copilot.vim";
      rev = "9e869d29e62e36b7eb6fb238a4ca6a6237e7d78b";
      sha256 = "0jzk1hd8kvh8bswdzbnbjn62r19l4j5klyni7gxbhsgbshfa3v87";
    };

    meta.homepage = "https://github.com/github/copilot.vim/";
  };
in
{
  programs.neovim = {
    plugins = [
      copilot-vim
    ];
  };
}
