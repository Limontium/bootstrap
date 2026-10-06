# Bootstrap

A lightweight bootstrap toolkit for setting up my Linux/macOS development environment.

It installs and configures the tools I use every day, including Zsh, Ghostty, Neovim, CLI utilities, fonts, and development dependencies.

## Quick install

Run:

```bash
bash -c "$(curl -fsSL https://gitlab.com/ukondoby/bootstrap/-/raw/main/bootstrap.sh)"
```

The bootstrap script downloads the repository into a temporary directory, runs the installer, and removes the temporary files afterward.

## What it installs

The current setup includes:

- Git
- Zsh
- Ghostty
- Neovim
- Lazygit
- Yazi
- Zoxide
- Eza
- Btop
- Ripgrep
- fd
- Node.js / npm
- jq
- ImageMagick
- Poppler
- 7-Zip
- Lilex Nerd Font
- Clipboard utilities and other Neovim dependencies

It also applies my Git, Zsh, Ghostty, and terminal configuration.

## Supported systems

The installer currently supports package-manager backends for:

- Arch Linux / Omarchy / Arch-based distributions
- Debian / Ubuntu-based distributions
- Fedora / RHEL-based distributions
- openSUSE
- Alpine Linux
- macOS via Homebrew

Some applications may have more complete support on certain distributions than others.

## Neovim configuration

My Neovim configuration is stored in a private GitLab repository.

The installer checks whether SSH access to GitLab is available.

If no SSH key exists, an Ed25519 key is generated automatically.

If the key is not registered in GitLab, the rest of the bootstrap continues normally and the public key is printed at the end.

Add the key here:

https://gitlab.com/-/user_settings/ssh_keys

Then run the installer again.

## Existing configuration

Existing configuration files are backed up before being replaced.

Backups use timestamped filenames, for example:

```text
~/.zshrc.bak.20260927_140059
```

Configuration files are copied rather than symlinked, so the bootstrap repository does not need to remain on the system after installation.

## Repository structure

```text
.
├── bootstrap.sh
├── install.sh
├── lib/
│   ├── core.sh
│   ├── detect.sh
│   ├── packages.sh
│   ├── package-map.sh
│   └── verify.sh
├── package-managers/
│   ├── apt.sh
│   ├── pacman.sh
│   ├── dnf.sh
│   ├── zypper.sh
│   ├── apk.sh
│   └── brew.sh
├── tests/
│   └── run.sh
├── modules/
│   ├── base.sh
│   ├── git.sh
│   ├── zsh.sh
│   ├── fonts.sh
│   ├── lazygit.sh
│   ├── yazi.sh
│   ├── neovim.sh
│   ├── nvim-config.sh
│   └── ghostty.sh
└── config/
    ├── zsh/
    └── ghostty/
```

## Notes

This project is primarily built for my own development environment, but the scripts are structured to make adding new distributions, package managers, and modules straightforward.
