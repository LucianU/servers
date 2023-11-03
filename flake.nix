{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.11";

    nixpkgs-latest.url = "github:NixOS/nixpkgs/23.05";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    tiddlywiki.url = "github:LucianU/nix-tiddlywiki";
    tiddlywiki.inputs.nixpkgs.follows = "nixpkgs";

    wikis.url = "/Users/lucian/code/web/wikis";
    wikis.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-latest";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-latest";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    niwos-wsl.inputs.nixpkgs.follows = "nixpkgs-latest";
  };

  outputs = inputs@{ nixpkgs, sops-nix, darwin, home-manager, nixos-wsl, ... }:
    let
      inherit (nixpkgs.lib) nixosSystem;
      inherit (darwin.lib) darwinSystem;
    in
    {
      nixosConfigurations = {
        "hetzner-main" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/hetzner-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "do-nixos-stage" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/do-nixos-stage/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-main" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/oci-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-snd" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/oci-snd/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "oci-arm-main" = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./machines/oci-arm-main/configuration.nix
            sops-nix.nixosModules.sops
          ];
          specialArgs = { inherit inputs; };
        };

        "asus-rog" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./machines/asus-rog/configuration.nix
            nixos-wsl.nixosModules.wsl
          ];
          specialArgs = { inherit inputs; };
        };
      };

      darwinConfigurations = {
        "Lucians-MacBook-Pro" = darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./machines/macbook-pro/configuration.nix
            home-manager.darwinModules.home-manager
          ];
        };
      };
    };
}
