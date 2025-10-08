# ~/.zshrc
# new machine setup: TODO install zsh instructions
#
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="blinks"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


[ -f ~/.zsh/env ] && source ~/.zsh/env
[ -f ~/.zsh/config ] && source ~/.zsh/config
[ -f ~/.zsh/aliases ] && source ~/.zsh/aliases
[ -f ~/.zsh/completions ] && source ~/.zsh/completions
[ -f ~/.zsh/paths ] && source ~/.zsh/paths
[ -f ~/.zsh/functions ] && source ~/.zsh/functions
[ -f ~/.zsh/exports ] && source ~/.zsh/exports

clean_nvim_open_history() {
    # Write current history to file
    fc -W

    # Check if last line contains tmux_nvim_open
    if tail -1 ~/.zsh_history | grep -q "tmux_nvim_open "; then
        # Remove last line
        sed -i '' '$d' ~/.zsh_history

        # Check for 'q' - zsh history format includes timestamp like ": 1234567890:0;q"
        if tail -1 ~/.zsh_history | grep -qE "(^|;)q$"; then
            # Remove that too
            sed -i '' '$d' ~/.zsh_history
        fi
    fi

    # Reload history
    fc -R
}

# Updated tmux_nvim_open function
tmux_nvim_open() {
    local input="$1"
    local explicit_line="${2:-}"

    # Remove trailing colons and parse file:line format
    input="${input%:}"
    if echo "$input" | grep -qE '^.+:[0-9]+:?[0-9]*$'; then
        file=$(echo "$input" | sed -E 's/:([0-9]+):?[0-9]*$//')
        line=$(echo "$input" | sed -E 's/^.+:([0-9]+):?[0-9]*$/\1/')
    else
        file="$input"
        line="${explicit_line:-1}"
    fi

    # Find first window.pane running nvim
    local nvim_target=$(tmux list-panes -a -F '#{window_index}.#{pane_index} #{pane_current_command}' | grep 'nvim$' | head -1 | awk '{print $1}')

    if [ -n "$nvim_target" ]; then
        # Switch to that window and pane
        tmux select-window -t "${nvim_target%%.*}"
        tmux select-pane -t "$nvim_target"

        # Send the commands
        tmux send-keys -t "$nvim_target" Escape ":e ${file}" C-m
        if [ "$line" != "1" ] && [ -n "$line" ]; then
            tmux send-keys -t "$nvim_target" ":${line}" C-m
        fi
    else
        # No nvim found, create a new window
        if [ "$line" != "1" ] && [ -n "$line" ]; then
            tmux new-window "nvim '$file' +$line"
        else
            tmux new-window "nvim '$file'"
        fi
    fi
}

# setopt transient_rprompt # don't show command modes on previously accepted lines

## Prompt


ZSH_THEME_CLOUD_PREFIX='⚡️'
ZSH_THEME_GIT_PROMPT_PREFIX=" [%{%B%F{blue}%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{%f%k%b%B%F{green}%}]"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{%F{red}%}*%{%f%k%b%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""

PROMPT='%{%f%k%b%}
%{%B%F{green}%}%n%{%B%F{blue}%}@%{%B%F{cyan}%}%m%{%B%F{green}%} %{%b%F{yellow}%}%~%{%B%F{green}%}$(git_prompt_info)%E%{%f%k%b%}
%{%B%F{cyan}%}$ZSH_THEME_CLOUD_PREFIX%{%f%k%b%}'

RPROMPT=''
RPROMPT2=''

if [ -d "$HOME/.nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
