# vim: ft=sh

# Enable color support if possible
if [ -x /usr/bin/dircolors ]; then
  test -r ${HOME}/.dircolors && eval "$(dircolors -b ${HOME}/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
  export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
fi

# Vim stuff
alias vim="~/scripts/vim"
alias :q="exit" # Sometimes I'm dumb and try to exit a terminal as if it is vim
alias :wq="exit"
alias q="exit"
alias i="vim -c 'startinsert'"

# quick cd's
alias cdst="cd ~/documents/Work/SpamTagger"

# shortcuts
alias c="clear"
alias t="date +%T"

# improve default options for CLI tools
alias diff="diff --side-by-side --left-column -W \$COLUMNS"
alias ll="ls -alh"

# OS functions (TODO: should be broken out and pulled in based on OS)
alias pip-upgrade="pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U"

# Legacy mappings
alias ifconfig="ip addr"

# SSH hop scripts
alias sshs="${HOME}/.private-scripts/sshs.sh"
alias pgen="ssh -A -t -i ~/.ssh/no_pass 10.10.0.1 ~/bin/pgen"

# Startup scripts
alias startsway="${HOME}/scripts/sway/startsway.sh"
alias starti3="${HOME}/scripts/i3/starti3.sh"

# Web shortcuts
alias papillon="flatpak run com.github.Eloston.UngoogledChromium --app='https://papillon.john.me.tz/hud.php?refresh=3600&theme=dark'"

# Force python3
alias python="python3"

# Flatpaks
alias mpv="flatpak run io.mpv.Mpv"

# Detect if I'm in a distrobox, returns name of box, if applicable
alias isdistrobox='[ -f "/run/.containerenv" ] && grep -oP "(?<=name=\")[^\";]+" /run/.containerenv'

# Flag that the directory was just changed (used with prompt)
alias cd='export DIRCHANGED="1"; cd'

if [ -f /etc/os-release ]; then
  export OS=$(grep -P '^ID=' /etc/os-release | cut -d'=' -f2 | sed 's/"//g')
  if [ -f ${HOME}/.dotfiles/bash/bash_aliases.$OS ]; then
    source ${HOME}/.dotfiles/bash/bash_aliases.$OS
  fi
  OSVARIANT=$(grep -P '^VARIANT_ID=' /etc/os-release | cut -d'=' -f2 | sed 's/"//g')
  if [ -z $OSVARIANT ]; then
    export OSVARIANT
  fi
  if [ -f ${HOME}/.dotfiles/bash/bash_aliases.$OS-$OSVARIANT ]; then
    source ${HOME}/.dotfiles/bash/bash_aliases.$OS-$OSVARIANT
  fi
fi

if [ "$(isdistrobox)" ]; then
  source "$HOME/.dotfiles/bash/bash_aliases.distrobox"
else
  source "$HOME/.dotfiles/bash/bash_aliases.host"
fi
