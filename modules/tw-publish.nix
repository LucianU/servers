{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-publish-pkg = inputs.wikis.packages.${config.nixpkgs.system}.publish;
    tiddlywiki-pkg = inputs.tiddlywiki.packages.${config.nixpkgs.system}.tiddlywiki;
  in
    mk-TW-Instance {
      service-name = "tw-publish";
      service-pkg = tw-publish-pkg;
      tiddlywiki-pkg = tiddlywiki-pkg;
      inherit config lib pkgs;
    }
