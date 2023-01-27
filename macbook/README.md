# Mac Nix Setup
This setup is meant to be used with `nix`, `nix-darwin` and `home-manager`.

It will cover as much as possible tasks such as:
* managing users
* managing programs
* managing services
* managing dotfiles

# Usage
To deploy the current configuration on the machine, run:

    darwin-rebuild switch --flake #.<machine>

Where `<machine>` is the name of the machine as defined in `flake.nix`.
