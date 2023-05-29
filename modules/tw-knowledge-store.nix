{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance.nix;
in
  let
    tw-knowledge-store-pkg = inputs.knowledge-store.packages.${config.nixpkgs.system}.knowledge-store;
  in
    mk-TW-Instance {
      service-name = "tw-knowledge-store";
      service-pkg = tw-knowledge-store-pkg;
      inherit config lib pkgs;
    }
