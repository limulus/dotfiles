# Eric's Dotfiles

Managed as a [bare git repository](https://www.atlassian.com/git/tutorials/dotfiles) checked out into `$HOME`.

## Bootstrap a new machine

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/limulus/dotfiles/main/.config/dotfiles/bootstrap.sh)"
```

The script clones this repo as a bare repo to `~/.dotfiles`, configures it, and checks the tracked files out into `$HOME`. Any pre-existing files that would be overwritten are renamed with a `.bak` suffix; the script prints each file it moves.

After it finishes, open a new shell (or `source ~/.zshrc`) so the `dot` alias is loaded.

## The `dot` alias

`.zshrc` defines:

```sh
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

`dot` is just `git` aimed at the bare repo with `$HOME` as the working tree. Use it exactly like git.

## Day-to-day usage

```sh
dot status                  # show changes to tracked files (untracked files are hidden)
dot add ~/.zshrc            # stage a change
dot commit -m "tweak prompt"
dot push
dot pull                    # pull updates on another machine
```

## Adding a new dotfile

Files are tracked at their path relative to `$HOME`. To start tracking one:

```sh
dot add ~/.gitconfig
dot commit -m "add gitconfig"
dot push
```

That tracks it as `.gitconfig` in the repo, and a fresh bootstrap on another machine will check it out to `~/.gitconfig`.

## VS Code devcontainers

VS Code can clone these dotfiles into any devcontainer it builds. Open the command palette (`Cmd+Shift+P` / `Ctrl+Shift+P`), run **Preferences: Open User Settings (JSON)**, and merge in:

```jsonc
{
  "dotfiles.repository": "limulus/dotfiles",
  "dotfiles.installCommand": ".config/dotfiles/bootstrap.sh",
  "terminal.integrated.defaultProfile.linux": "zsh"
}
```

VS Code clones the repo into `~/dotfiles` inside the container and runs the install command. `bootstrap.sh` then sets up the bare repo at `~/.dotfiles` and checks tracked files out into `$HOME` — same flow as on a fresh machine. The `defaultProfile` line makes VS Code's terminal launch zsh; the container image needs zsh installed (Microsoft's base images include it via the `common-utils` devcontainer feature).

See [Personalizing with dotfile repositories](https://code.visualstudio.com/docs/devcontainers/containers#_personalizing-with-dotfile-repositories) for the full list of related settings (e.g. `dotfiles.targetPath`).

## Notes

- `status.showUntrackedFiles=no` is set on the bare repo by the bootstrap script. Without it, `dot status` would list every file in `$HOME` as untracked.
- Bootstrap refuses to run if `~/.dotfiles` already exists. To start over, `rm -rf ~/.dotfiles` first.
