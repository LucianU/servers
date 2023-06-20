{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-sim-pkg = inputs.wikis.packages.${config.nixpkgs.system}.sim;
    tiddlywiki-pkg = inputs.tiddlywiki.packages.${config.nixpkgs.system}.tiddlywiki;
  in
    mk-TW-Instance {
      service-name = "tw-sim";
      service-pkg = tw-sim-pkg;
      tiddlywiki-pkg = tiddlywiki-pkg;
      inherit config lib pkgs;
    }
