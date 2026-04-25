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
summary_file=$(mktemp)
trap 'rm -f "$checkout_output" "$summary_file"' EXIT

if ! dot checkout 2>"$checkout_output"; then
    conflicts=$(awk '/^[[:space:]]/ { sub(/^[[:space:]]+/, ""); print }' "$checkout_output")
    if [ -z "$conflicts" ]; then
        printf 'error: dot checkout failed:\n' >&2
        cat "$checkout_output" >&2
        exit 1
    fi
    printf '%s\n' "$conflicts" | while IFS= read -r file; do
        [ -z "$file" ] && continue
        target="$HOME/$file"
        [ -e "$target" ] || continue
        head_content=$(mktemp)
        if dot show "HEAD:$file" >"$head_content" 2>/dev/null && cmp -s "$target" "$head_content"; then
            rm -f "$target" "$head_content"
            continue
        fi
        backup=$(backup_path "$target")
        mkdir -p "$(dirname "$backup")"
        {
            printf '\033[33m%s -> %s\033[0m\n' "$target" "$backup"
            diff -u "$head_content" "$target" 2>/dev/null | tail -n +3 | awk '
                /^@@/ { printf "\033[36m%s\033[0m\n", $0; next }
                /^-/  { printf "\033[31m%s\033[0m\n", $0; next }
                /^\+/ { printf "\033[32m%s\033[0m\n", $0; next }
                { print }
            ' | sed 's/^/    /'
            printf '\n'
        } >>"$summary_file"
        rm -f "$head_content"
        mv "$target" "$backup"
    done
    if ! dot checkout; then
        printf 'error: dot checkout still failed after backing up conflicts\n' >&2
        exit 1
    fi
fi

dot branch --set-upstream-to=origin/main main >/dev/null 2>&1 || true

current_shell="${SHELL:-}"
case "${current_shell##*/}" in
    zsh)
        ;;
    *)
        printf '\nnote: current login shell is %s\n' "${current_shell:-unknown}"
        printf 'switch to zsh with: chsh -s "$(command -v zsh)"\n'
        ;;
esac

printf '\ndone. bare repo at %s\n' "$DOTFILES_DIR"
printf 'open a new shell or run: source ~/.zshrc\n'

if [ -s "$summary_file" ]; then
    printf '\n\033[1;33mFiles backed up to avoid conflicts (HEAD vs local diff below):\033[0m\n\n'
    sed 's/^/  /' "$summary_file"
fi
