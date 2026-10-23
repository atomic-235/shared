# shared

Home-manager modules, overlays and the Neovim configuration shared by two
setups: the private NixOS dotfiles and [portable](https://github.com/atomic-235/portable)
(any Linux VM with Nix). Nothing here is machine-specific — personal configs,
GUI tools and secrets stay in the consumers.

## Modules

`homeManagerModules.<name>`:

`bash`, `btop`, `delta`, `lazysql`, `lazygit`, `neovim`, `opencode`, `packages`,
`shell-tools` (fzf/zoxide/direnv), `starship`, `termusic`, `tmux`, `yazi`.

`modules/packages.nix` also installs the tree-sitter parsers used by Neovim and
a few small CLI scripts (`gittop-all`, `with-secrets`, `with-jail`).

## Overlays

`overlays.default` (= `defaultOverlay`) composes the release flakes into one
attribute set:

| Attribute | Source |
|---|---|
| `opencode` | `opencode-flake` |
| `venice-mcp-server` | `venice-mcp-flake` |
| `swls` | `swls-flake` |
| `tmux` | `tmux-flake` |
| `lazygit` | `lazygit-flake` |
| `gittop` | `gittop-flake` |
| `tree-sitter-clingo`, `tree-sitter-cypher` | grammar flakes |
| `with-secrets`, `with-jail` | `scripts/` |

Patched nixpkgs packages (waybar, the xdg-desktop-portal family,
amd-debug-tools) live in [cached](https://github.com/atomic-235/cached) instead,
because they must be built against the exact nixpkgs pin. Consumers apply
`cached.overlays.default` after `shared.defaultOverlay`.

## Usage

```nix
{
  inputs.shared.url = "github:atomic-235/shared";
  inputs.shared.inputs.nixpkgs.follows = "nixpkgs";
}
```

```nix
home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ shared.defaultOverlay cached.overlays.default ];
  };
  modules = [
    shared.homeManagerModules.bash
    shared.homeManagerModules.neovim
    shared.homeManagerModules.packages
    # ...
  ];
}
```

`neovim` needs a `nvimRelativePath` in `extraSpecialArgs` (and `--impure`), e.g.
`"projects/personal/dotfiles/submodules/shared/nvim"`. It creates an
out-of-store symlink so `:Lazy update` can rewrite `lazy-lock.json`.

## Layout

```
modules/     home-manager modules
nvim/        LazyVim configuration (symlinked, not copied)
scripts/     with-secrets, with-jail, helper scripts
flake.nix    module/overlay exports
```
