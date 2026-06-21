# User executables
export PATH=$HOME/bin:$HOME/.local/bin:$HOME/.local/n/bin:$HOME/.local/lima/bin:$PATH

# Timezone (derived from system if not already set, so devcontainers can inherit it)
if [[ -z $TZ && -L /etc/localtime ]]; then
  export TZ=${$(readlink /etc/localtime)#*/zoneinfo/}
fi

# History (zsh persists nothing unless HISTFILE is set and SAVEHIST > 0;
# macOS sets these via /etc/zshrc, but Linux/devcontainers do not)
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY        # share history across concurrent sessions
setopt HIST_IGNORE_DUPS     # don't record consecutive duplicate commands
setopt HIST_IGNORE_SPACE    # commands prefixed with a space stay out of history

# Bash autocomplete compatibility
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Git Autocomplete
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

# Dotfiles (bare repo at ~/.dotfiles managed via the `dot` alias)
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# Plain path completion for `dot` (else the alias inherits git's add-completion,
# which won't complete new/untracked paths). Trade-off: no subcommand completion.
setopt complete_aliases
compdef _files dot

# n Node Version Manager
export N_PREFIX=$HOME/.local/n

# AWS
export PATH=$HOME/.local/aws/aws-cli:$PATH

# AWS CLI Autocomplete (needs to happen last for some reason)
complete -C aws_completer aws

# Left Prompt Setup
setopt prompt_subst
PROMPT='%(?.%F{green}✓.%F{red}[%?]) %B%F{240}%m %1~%f%b %# '
zstyle ':vcs_info:git:*' formats '%B%F{240}⑆ %b%%b%f'

# Right Side Prompt Setup
# Skips VS Code due to Copilot terminal issues with right side prompts
if [[ "$TERM_PROGRAM" != "vscode" ]]; then
    setopt prompt_subst
    zstyle ':vcs_info:git:*' formats '%%F{#777777}⑆ %%B%b%%f%%b'
    RPROMPT='${vcs_info_msg_0_}'
fi

# --- OS-specific config ---
# Pattern for Linux-only settings: gate on $OSTYPE (zsh sets it to
# "linux-gnu*" on Linux and "darwin*" on macOS).
if [[ "$OSTYPE" == linux-gnu* ]]; then
  # Lima (Linux VM) appends this exact block to .profile/.bashrc/.zshrc on
  # boot UNLESS it already finds the "# Lima BEGIN" marker. Carrying it here
  # keeps Lima from mutating this dotfiles-tracked file, so `dot pull` stays
  # conflict-free. /usr/sbin:/sbin make iptables & mount.fuse3 reachable.
  # Lima BEGIN
  PATH="$PATH:/usr/sbin:/sbin"
  export PATH
  # Lima END
fi

if [[ "$OSTYPE" == darwin* ]]; then
  # Shell into the cochineal sandbox VM. Mirror the cwd only under ~/Developer,
  # the one path shared with the guest; elsewhere it doesn't exist there.
  cochineal() {
    if [[ "$PWD" == "$HOME/Developer" || "$PWD" == "$HOME/Developer/"* ]]; then
      limactl shell --workdir "$PWD" cochineal "$@"
    else
      limactl shell cochineal "$@"
    fi
  }
fi

# Machine-local zsh drop-ins (untracked; e.g. files provisioned into a VM).
# Keeps environment-specific config out of these portable dotfiles.
for _zf in "$HOME"/.config/zsh/*.zsh(N); do source "$_zf"; done
unset _zf

