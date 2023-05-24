{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-publish-pkg = inputs.wikis.packages.${config.nixpkgs.system}.publish;
  tw-publish = tw-service {
    service-name = "tw-publish";
    service-pkg = tw-publish-pkg;
    inherit config lib pkgs;
  };
in
  tw-publish
