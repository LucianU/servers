{ config, lib, pkgs, inputs, ... }:

let
  tw-service = import ./tw-service.nix;
  tw-haskell-v2-pkg = inputs.wikis.packages.${config.nixpkgs.system}.haskell;
  tw-haskell-v2 = tw-service {
    service-name = "tw-haskell-v2";
    service-pkg = tw-haskell-v2-pkg;
    inherit config lib pkgs;
  };
in
  tw-haskell-v2
