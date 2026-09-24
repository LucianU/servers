# Standalone macOS configuration

These files preserve the current Home Manager settings without depending on
generated files in `/nix/store`. They are staged here; the live files in the
home directory are still managed by Home Manager.

| Repository file | Home-directory destination |
| --- | --- |
| `bash/profile` | `~/.profile` |
| `bash/bash_profile` | `~/.bash_profile` |
| `bash/bashrc` | `~/.bashrc` |
| `git/config` | `~/.config/git/config` |
| `git/ignore` | `~/.config/git/ignore` |
| `direnv/direnv.toml` | `~/.config/direnv/direnv.toml` |
| `htop/htoprc` | `~/.config/htop/htoprc` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `irssi/config` | `~/.irssi/config` |
| `neovim/no-nix-init.lua` | `~/.config/nvim/init.lua` |

The Neovim config loads its other files from `neovim/components/`, so its entry
point should be symlinked rather than copied. `~/.config/neovim/init.lua`
already points to the same standalone config.

Install replacement tools and change iTerm's Bash path before unlinking the
Home Manager files or removing Nix. The Bash completion setup is optional and
loads only when Homebrew's `bash-completion@2` is present. The direnv config
does not include `nix-direnv`; its generated library link should be removed
when Nix is retired. Keep the private SOPS age key at
`~/.config/sops/age/keys.txt` outside this repository.
