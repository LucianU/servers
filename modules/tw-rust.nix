{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-rust-pkg = inputs.wikis.packages.${config.nixpkgs.system}.rust;
  tw-rust = tw-service {
    service-name = "tw-rust";
    service-pkg = tw-rust-pkg;
    inherit config lib pkgs;
  };
in
  tw-rust
