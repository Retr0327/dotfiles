# dotfiles

A comprehensive guide for my future self, so I don't have to time travel.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Tool Configurations](#tool-configurations)
  - [tmux](#tmux)
  - [cspell](#cspell)

---

## Prerequisites

| Tool | Minimum Version | Installation |
| --- | --- | --- |
| **Neovim** | 0.11+ | `brew install neovim` |
| **tmux** | 3.3+ | `brew install tmux` |
| **Node.js** | 22+ | [nvm](https://github.com/nvm-sh/nvm) |
| **pnpm** | 10+ | `npm install -g pnpm` |
| **Ghostty** | 1.3+  | [ghostty](https://ghostty.org/) |
| **ripgrep** | 14+ | `brew install ripgrep` (Required for Snacks picker grep) |
| **fd** | 10+ | `brew install fd` (Required for Snacks picker files) |
| **fzf** | 0.61+ | `brew install fzf` (Required for tmux sessionizer) |
| **lazygit** | 0.45+ | `brew install lazygit` (Opened via `<leader>gg` in nvim) |

---

## Fonts

Both Neovim and Ghostty use **Nerd Font** to display icons. Currently using:

- **JetBrainsMono Nerd Font**
- **PingFang TC** (Chinese fallback, macOS built-in)

Download JetBrainsMono Nerd Font:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

Or manually download `JetBrainsMono.zip` from [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases), extract and install the `.ttf` files.

---

## Installation Steps

### 1. Clone repo

> Backup existing config: `mv ~/.config ~/.config.bak`

```bash
git clone <YOUR_REPO_URL> ~/.config
```

### 2. Create necessary directories

```bash
mkdir -p ~/.vim/undodir
```

Neovim's undo persistence will store files in this directory.

### 3. Install cspell dictionaries

```bash
cd ~/.config/cspell/dicts && pnpm install
```

This will install the language dictionaries required by cspell (Go, Node, Python, TypeScript, Vim).

### 4. Install tmux plugin manager (TPM)

```bash
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

After installing TPM, start tmux and press `prefix` + `I` (capital i) to install all plugins.

> prefix has been changed to `Ctrl+Space`

#### tmux plugin list

| Plugin | Purpose |
| --- | --- |
| [tpm](https://github.com/tmux-plugins/tpm) | Plugin manager |
| [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible) | Sensible defaults |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless navigation between vim and tmux panes |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Copy to system clipboard |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Restore session after restart |
| [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum) | Auto-save/restore session (every 5 minutes) |
| [tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url) | Open URLs in terminal using fzf |

#### Catppuccin theme (Manual installation)

The Catppuccin theme for tmux is not installed via TPM and needs to be cloned manually:

```bash
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
```

### 5. Start Neovim

```bash
nvim
```

On first startup, [lazy.nvim](https://github.com/folke/lazy.nvim) automatically bootstraps and installs all plugins. Once complete, Mason will then automatically install the required LSP servers, linters, and formatters via `mason-tool-installer`.

To enable GitHub Copilot, run the following command inside Neovim and follow the prompts to authenticate:

```vim
:Copilot auth
```

## Tool Configurations

### tmux

- **Prefix:** `Ctrl+Space` (replaces default `Ctrl+b`)
- **Config file:** `~/.config/tmux/tmux.conf`
- **Reload:** `prefix` + `r`

#### Keybindings

| Keybinding | Description |
| --- | --- |
| `prefix + f` | tmux sessionizer (fzf select project directory and switch session) |
| `Alt+H` / `Alt+L` | Previous / next window |
| `prefix + hjkl` | Resize pane |
| `Ctrl+hjkl` | Switch between vim and tmux panes (vim-tmux-navigator) |
| `prefix + Space` | Switch to previous session |
| `prefix + Enter` | Toggle pane zoom |

#### tmux sessionizer

`~/.config/tmux/bin/tmux_sessionizer` is an fzf menu that searches for project directories to switch sessions.

The search paths are configured in `~/.config/tmux/bin/paths.zsh`. By default, it includes:

```zsh
# Directories to search for projects (max depth 1)
search_paths=(
    "$HOME/.config"
    "$HOME/<YOUR_PROJECT_PATH>"
)

# Exact paths to exclude from the fzf menu
exclude_paths=(
    "$HOME/<YOUR_PROJECT_PATH>/node_modules"
)

# Exact paths to append directly to the fzf menu (bypassing search)
append_paths=(
    "$HOME/<SPECIFIC_PROJECT_PATH>"
)
```

You can modify the `search_paths`, `exclude_paths`, and `append_paths` arrays in `paths.zsh` according to your project structure.

### cspell

Global spell check configuration, `nvim-lint` in Neovim will check spelling via cspell after each save.

- **Config file:** `~/.config/cspell/cspell.yml`
- **Custom dictionary:** `~/.config/cspell/custom.txt`
- **Language dictionaries:** Managed via `~/.config/cspell/dicts/package.json` (pnpm)

In Neovim, press `<leader>as` to quickly add the word under the cursor to the custom dictionary.

---

## Quick Setup Commands Overview

On a brand new Mac, the complete installation process:

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install all tools
brew install neovim tmux ripgrep fd fzf lazygit

# 3. Install Nerd Font
brew install --cask font-jetbrains-mono-nerd-font

# 4. Clone dotfiles
git clone <YOUR_REPO_URL> ~/.config

# 5. Create undo directory
mkdir -p ~/.vim/undodir

# 6. Install cspell dictionaries
cd ~/.config/cspell/dicts && pnpm install && cd -

# 7. Install TPM (tmux plugin manager)
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 8. Install Catppuccin tmux theme
mkdir -p ~/.config/tmux/plugins/catppuccin
git clone https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux

# 9. Start tmux and install plugins
tmux
# In tmux, press Ctrl+Space then press I (capital i) to install plugins

# 10. Start Neovim (automatically installs plugins)
nvim
# Wait for lazy.nvim installation to finish, then restart Neovim
# Mason will automatically install LSP servers, linters, formatters
```
