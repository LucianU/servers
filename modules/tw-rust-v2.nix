{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-rust-v2-pkg = inputs.wikis.packages.${config.nixpkgs.system}.rust;
  tw-rust-v2 = tw-service {
    service-name = "tw-rust-v2";
    service-pkg = tw-rust-v2-pkg;
    inherit config lib pkgs;
  };
in
  tw-rust-v2
