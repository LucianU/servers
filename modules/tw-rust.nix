{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-rust-pkg = inputs.wikis.packages.${config.nixpkgs.system}.rust;
    tiddlywiki-pkg = inputs.tiddlywiki.packages.${config.nixpkgs.system}.tiddlywiki;
  in
    mk-TW-Instance {
      service-name = "tw-rust";
      service-pkg = tw-rust-pkg;
      tiddlywiki-pkg = tiddlywiki-pkg;
      inherit config lib pkgs;
    }
