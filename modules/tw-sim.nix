{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-sim-pkg = inputs.wikis.packages.${config.nixpkgs.system}.sim;
  tw-sim = tw-service {
    service-name = "tw-sim";
    service-pkg = tw-sim-pkg;
    inherit config lib pkgs;
  };
in
  tw-sim
