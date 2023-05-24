{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-knowledge-store-pkg = inputs.knowledge-store.packages.${config.nixpkgs.system}.knowledge-store;
  tw-knowledge-store = tw-service {
    service-name = "tw-knowledge-store";
    service-pkg = tw-knowledge-store-pkg;
    inherit config lib pkgs;
  };
in
  tw-knowledge-store
