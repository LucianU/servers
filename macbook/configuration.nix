{ config, pkgs, ... }:

{
  imports = [
    <home-manager/nix-darwin>
  ];

  nix.binaryCaches = [
    "https://cache.nixos.org/"
  ];
  nix.binaryCachePublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
  nix.trustedUsers = [
    "@admin"
  ];

  users.nix.configureBuildUsers = true;
  users.users.lucian = {
    name = "lucian";
    home = "/Users/lucian";
  };

  # Enable experimental nix command and flakes
  # nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    auto-optimise-store = true
    experimental-features = nix-command flakes
    extra-platforms = x86_64-darwin aarch64-darwin
  '';

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=<path/to/configuration.nix>
  environment.darwinConfig = "$HOME/.config/nix/configuration.nix";

  environment.systemPackages =
    [ pkgs.kitty
      pkgs.vim
    ];

  home-manager.useUserPackages = true;
  home-manager.users.lucian = import ./home.nix;


  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
