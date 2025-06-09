# vim: ft=sh

# Get last run command
function last_command {
    local h="$(history 1)";
    echo "${h##*([[:space:])+([[:digit:]])+([[:space:]])}"
}

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# Load default $TERM as $TERM_TITLE if not provided by alacritty config
if [[ -z $TERM_TITLE ]]; then
    TERM_TITLE="$TERM";
fi

# agetty is set to automatically log me in on tty1
# Automatically launch GUI on tty1 after login
# I don't think that this is used anymore in Sericea, I think autologin is handled by SDDM
# Still, it does not hurt for later distrohopping
if [ "$(tty)" == '/dev/tty1' ] && [ ! "$SSH_TTY" ]; then
    source "${HOME}/.dotfiles/bash/bash_login"
    # If this flag file does not exist then don't attempt to start any session
    # It should be removed when logging out of a session to prevent immediate re-login
    if [ -f "${HOME}/.local/state/last_login_gui" ]; then
        # File should contain i3 or sway, depending on the last `start(i3|sway)` command run
        LAST_GUI=$(cat "${HOME}/.local/state/last_login_gui" 2>/dev/null)
        ${HOME}/scripts/${LAST_GUI}/start${LAST_GUI}.sh
    fi
fi

# Shell configuration (history, functionality, etc.)
if [ -e ${HOME}/.dotfiles/bash/shell_config ]; then
    source ${HOME}/.dotfiles/bash/shell_config
fi

# Distrobox-specific or host-specific configs (loads $DISTROBOX variable, necessary for PATH)
if [ -f "/run/.containerenv" ]; then
    source "$HOME/.dotfiles/bash/bashrc.distrobox"
else
    source "$HOME/.dotfiles/bash/bashrc.host"
fi

# Configure PATH
source "$HOME/.dotfiles/bash/path"

# Static environment variable exports
if [ -f ${HOME}/.dotfiles/bash/env_exports ]; then
    . "${HOME}/.dotfiles/bash/env_exports"
fi

# Load aliases
if [ -f ${HOME}/.dotfiles/.bash_aliases ]; then
    . "${HOME}/.dotfiles/.bash_aliases"
fi

# Rust 
. "$HOME/.cargo/env"
# Perl
eval "$(plenv init -)"
source ${HOME}/.dotfiles/bash/plenv-path.sh

# Set initial title
echo -e -n "\033]2;Welcome to Bash - $TERM_TITLE\007"

# Set window title to last command
PS0='\[\e]0;$(last_command) - $TERM_TITLE\a\]'

# Run fetch to clarify which OS we are using
if [[ -n "$(which fastfetch 2> /dev/null)" ]]; then
    if [ -n $DISTROBOX ] && [ -e ${HOME}/.dotfiles/.config/fastfetch/${DISTROBOX}.jsonc ]; then
        fastfetch -C ${HOME}/.dotfiles/.config/fastfetch/${DISTROBOX}.jsonc
    else
        fastfetch -C ${HOME}/.dotfiles/.config/fastfetch/config.jsonc
    fi
fi

# Set a one-time flag that this is a new bash session
NEW_SHELL=1

# Use script to generate new $PS1 after each command
PROMPT_COMMAND="source ${HOME}/.dotfiles/bash/prompt.sh"
# Bell when prompt is returned to mark as urgent
PROMPT_COMMAND="$PROMPT_COMMAND;printf \"\a\""
# Append previous command to history immediately
PROMPT_COMMAND="$PROMPT_COMMAND;history -a"
