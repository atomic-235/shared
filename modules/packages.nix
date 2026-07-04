{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Editors
    neovim
    btop

    # CLI tools
    git
    gh
    eza
    bat
    fd
    ripgrep
    jq
    curl
    wget
    gum
    delta

    # Tools used by shared modules
    # (fzf, zoxide, direnv, starship, lazygit, yazi installed via programs.*.enable)
    # (sops, age installed via with-secrets runtimeInputs)
  ];
}
