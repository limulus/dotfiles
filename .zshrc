# User executables
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# Timezone (derived from system if not already set, so devcontainers can inherit it)
if [[ -z $TZ && -L /etc/localtime ]]; then
  export TZ=${$(readlink /etc/localtime)#*/zoneinfo/}
fi

# Bash autocomplete compatibility
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit

# Git Autocomplete
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )

# Dotfiles (bare repo at ~/.dotfiles managed via the `dot` alias)
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# n Node Version Manager
export N_PREFIX=$HOME/.local

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

