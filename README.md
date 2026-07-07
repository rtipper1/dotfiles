# dotfiles

Personal configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Each top-level directory is a Stow *package* whose contents mirror the layout of
your home directory. For example, `nvim/.config/nvim/init.lua` gets symlinked to
`~/.config/nvim/init.lua`.

## Packages

- `ghostty` – Ghostty terminal config
- `nvim` – Neovim config
- `starship` – Starship prompt config
- `tmux` – tmux config

## Install

1. Install GNU Stow:

   ```bash
   # Debian/Ubuntu
   sudo apt install stow

   # macOS (Homebrew)
   brew install stow

   # Arch
   sudo pacman -S stow
   ```

2. Clone this repo into your home directory:

   ```bash
   git clone <repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

3. Stow the packages you want. Run from the repo root; Stow symlinks into the
   parent directory (`~`) by default:

   ```bash
   # Install a single package
   stow nvim

   # Install several packages
   stow ghostty nvim starship tmux

   # Install everything
   stow */
   ```

## Updating

After editing a config, changes take effect immediately since the files are
symlinked. To re-link after adding new files to a package:

```bash
stow -R nvim   # restow (unlink then link again)
```

## Uninstall

Remove the symlinks for a package with `-D`:

```bash
stow -D nvim
```

## Notes

- If Stow reports a conflict, an existing (non-symlink) file is in the way.
  Back it up or remove it, then re-run `stow`.
