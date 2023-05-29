{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance.nix;
in
  let
    tw-publish-pkg = inputs.wikis.packages.${config.nixpkgs.system}.publish;
  in
    mk-TW-Instance {
      service-name = "tw-publish";
      service-pkg = tw-publish-pkg;
      inherit config lib pkgs;
    }
