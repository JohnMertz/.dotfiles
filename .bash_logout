# vim: ft=sh

# Pretty much everything cleans itself up adequately

if [ -f "/run/.containerenv" ]; then
    source "$HOME/.dotfiles/bash/bash_logout.distrobox"
else
    source "$HOME/.dotfiles/bash/bash_logout.host"
fi
