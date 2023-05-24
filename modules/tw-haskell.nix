{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-haskell-pkg = inputs.wikis.packages.${config.nixpkgs.system}.haskell;
  tw-haskell = tw-service {
    service-name = "tw-haskell";
    service-pkg = tw-haskell-pkg;
    inherit config lib pkgs;
  };
in
  tw-haskell
