# vim: ft=sh

# If running bash (vs. login prompt)
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
elif [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec sway -c $USER/.config/sway/config &> $USER/.local/state/sway.log
fi

# GUI themes
export GTK_THEME="Gruvbox"
export ICON_THEME="Gruvbox"
export CURSOR_THEME="FlatbedCursors-White"
export PROFILE_NAME="Oled"
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_QPA_PLATFORM="wayland-egl;wayland;xcb"
export GDK_BACKEND="wayland"
export DCONF=".config/dconf/user"
export THEME="dark"

# Perl junk to allow scripts to run for non-interactive sessions
eval "$(plenv init -)"

source "$HOME/.dotfiles/bash/path"
if [ -f "/run/.containerenv" ]; then
    source "$HOME/.dotfiles/bash/bash_profile.distrobox"
else
    source "$HOME/.dotfiles/bash/bash_profile.host"
fi

# XDG directories. Uppercase is dumb and this also slightly obscures where useful data is.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/desktop"
export XDG_DESKTOP_DIR="$HOME/desktop"
export XDG_DOCUMENTS_DIR="$HOME/documents"
export XDG_DOWNLOAD_DIR="$HOME/downloads"
export XDG_MUSIC_DIR="$HOME/music"
export XDG_PICTURES_DIR="$HOME/pictures"
export XDG_PUBLICSHARE_DIR="$HOME/public"
export XDG_TEMPLATES_DIR="$HOME/templates"
export XDG_VIDEOS_DIR="$HOME/videos"
export XDG_SCREENSHOTS_DIR="$HOME/pictures/screenshots"
