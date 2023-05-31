{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance;
in
  let
    tw-sim-pkg = inputs.wikis.packages.${config.nixpkgs.system}.sim;
  in
    mk-TW-Instance {
      service-name = "tw-sim";
      service-pkg = tw-sim-pkg;
      inherit config lib pkgs;
    }
