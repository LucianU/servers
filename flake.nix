{
  inputs = {
    nixpkgs-2305.url = "github:NixOS/nixpkgs/23.05";

    nixpkgs-2211.url = "github:NixOS/nixpkgs/22.11";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-2211";

    tiddlywiki.url = "github:LucianU/nix-tiddlywiki";

    wikis.url = "/Users/lucian/code/wikis";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-2305";

    home-manager.url = "github:nix-community/home-manager/release-23.05";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
  };

  outputs = inputs@{ nixpkgs-2305, nixpkgs-2211, sops-nix, darwin, home-manager, nixos-wsl, ... }:
    let
      inherit (nixpkgs-2211.lib) nixosSystem;
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
        {
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
