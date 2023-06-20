{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-knowledge-store-pkg = inputs.knowledge-store.packages.${config.nixpkgs.system}.knowledge-store;
    tiddlywiki-pkg = inputs.tiddlywiki.packages.${config.nixpkgs.system}.tiddlywiki;
  in
    mk-TW-Instance {
      service-name = "tw-knowledge-store";
      service-pkg = tw-knowledge-store-pkg;
      tiddlywiki-pkg = tiddlywiki-pkg;
      inherit config lib pkgs;
    }
