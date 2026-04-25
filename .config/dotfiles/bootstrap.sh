#!/bin/sh
# Bootstrap a new machine from this dotfiles bare repo.
#
# Run via:
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/limulus/dotfiles/main/.config/dotfiles/bootstrap.sh)"

set -eu

REPO_URL="${DOTFILES_REPO:-https://github.com/limulus/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"

if ! command -v git >/dev/null 2>&1; then
    printf 'error: git is required but not installed\n' >&2
    exit 1
fi

if [ -e "$DOTFILES_DIR" ]; then
    printf 'error: %s already exists; remove it or set DOTFILES_DIR to a different path\n' "$DOTFILES_DIR" >&2
    exit 1
fi

printf 'cloning %s -> %s\n' "$REPO_URL" "$DOTFILES_DIR"
git clone --bare "$REPO_URL" "$DOTFILES_DIR"

dot() {
    git --git-dir="$DOTFILES_DIR/" --work-tree="$HOME" "$@"
}

dot config status.showUntrackedFiles no
dot config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
dot fetch origin >/dev/null 2>&1 || true

backup_path() {
    base="$1.bak"
    candidate="$base"
    n=1
    while [ -e "$candidate" ]; do
        candidate="$base.$n"
        n=$((n + 1))
    done
    printf '%s' "$candidate"
}

checkout_output=$(mktemp)
trap 'rm -f "$checkout_output"' EXIT

if ! dot checkout 2>"$checkout_output"; then
    conflicts=$(awk '/^[[:space:]]/ {print $1}' "$checkout_output")
    if [ -z "$conflicts" ]; then
        printf 'error: dot checkout failed:\n' >&2
        cat "$checkout_output" >&2
        exit 1
    fi
    printf '%s\n' "$conflicts" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        target="$HOME/$file"
        [ -e "$target" ] || continue
        backup=$(backup_path "$target")
        mkdir -p "$(dirname "$backup")"
        mv "$target" "$backup"
        printf 'backed up: %s -> %s\n' "$target" "$backup"
    done
    if ! dot checkout; then
        printf 'error: dot checkout still failed after backing up conflicts\n' >&2
        exit 1
    fi
fi

dot branch --set-upstream-to=origin/main main >/dev/null 2>&1 || true

case "${SHELL##*/}" in
    zsh)
        ;;
    *)
        printf '\nnote: current login shell is %s\n' "$SHELL"
        printf 'switch to zsh with: chsh -s "$(command -v zsh)"\n'
        printf '(on macOS, ensure that path is listed in /etc/shells first)\n'
        ;;
esac

printf '\ndone. bare repo at %s\n' "$DOTFILES_DIR"
printf 'open a new shell or run: source ~/.zshrc\n'
