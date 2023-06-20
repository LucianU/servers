{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-haskell-pkg = inputs.wikis.packages.${config.nixpkgs.system}.haskell;
    tiddlywiki-pkg = inputs.tiddlywiki.packages.${config.nixpkgs.system}.tiddlywiki;
  in
    mk-TW-Instance {
      service-name = "tw-haskell";
      service-pkg = tw-haskell-pkg;
      tiddlywiki-pkg = tiddlywiki-pkg;
      inherit config lib pkgs;
    }
