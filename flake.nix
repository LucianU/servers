{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.05";

    nixpkgs-old.url = "github:NixOS/nixpkgs/22.11";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-old";

    tiddlywiki.url = "github:LucianU/nix-tiddlywiki";
    tiddlywiki.inputs.nixpkgs.follows = "nixpkgs-old";

    wikis.url = "/Users/lucian/code/wikis";
    wikis.inputs.nixpkgs.follows = "nixpkgs-old";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
  };

  outputs = inputs@{ nixpkgs, nixpkgs-old, sops-nix, darwin, home-manager, nixos-wsl, nixd, ... }:
    let
      inherit (nixpkgs-old.lib) nixosSystem;
      inherit (darwin.lib) darwinSystem;
    in
    {
      nixosConfigurations = {
        "hetzner-main" = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/hetzner-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-main" = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/oci-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-snd" = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/oci-snd/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-arm-main" = nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./machines/oci-arm-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "asus-rog" = nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/asus-rog/configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
          specialArgs = { inherit inputs; };
        };
      };

      darwinConfigurations =
        let
          overlay = ({ config, pkgs, lib, ... }:
            {
              nixpkgs.overlays = [
                (final: prev: {
                  nixd = nixd.packages."aarch64-darwin".nixd;
                })
              ];
            });
        in
        {
          "Lucians-MacBook-Pro" = darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./machines/macbook-pro/configuration.nix
              home-manager.darwinModules.home-manager
              overlay
            ];
        };
      };
    };
}
