{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.11";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    knowledge-store.url = "/Users/lucian/code/web/knowledge-store";
    knowledge-store.inputs.nixpkgs.follows = "nixpkgs";

    wikis.url = "/Users/lucian/code/web/wikis";
    wikis.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, sops-nix, ... }: {
    nixosConfigurations = {
      "knowledge-store" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./knowledge-store/configuration.nix
          sops-nix.nixosModules.sops
        ];
        specialArgs = { inherit inputs; };
      };

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
    };
  };
}
