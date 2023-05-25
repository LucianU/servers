{ config, lib, pkgs, inputs, ... }:

let
  mk-TW-Instance = import ./mk-tw-instance.nix;
in
  let
    tw-rust-pkg = inputs.wikis.packages.${config.nixpkgs.system}.rust;
  in
    mk-TW-Instance {
      service-name = "tw-rust";
      service-pkg = tw-rust-pkg;
      inherit config lib pkgs;
    };
