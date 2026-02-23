# vim: ft=bash

# TODO: Update explainer to properly parse path and git info

# Record the return value from previous command
RET=$?

# User to be represented with  abreviation
DEFAULT_USER=jpm

declare -A SIGNALS='(
    [129]='HUP'
    [130]='INT'
    [131]='QUIT'
    [132]='ILL'
    [133]='TRAP'
    [134]='ABRT'
    [135]='IOT'
    [136]='BUS'
    [137]='FPE'
    [138]='KILL'
    [149]='USR1'
    [140]='SEGV'
    [141]='USR2'
    [142]='PIPE'
    [143]='ALRM'
    [144]='TERM'
    [145]='STKFLT'
    [146]='CHLD'
    [147]='CONT'
    [148]='STOP'
    [149]='TSTP'
    [150]='TTIN'
    [151]='TTOU'
    [152]='URG'
    [153]='XCPU'
    [154]='XFSZ'
    [155]='VTALRM'
    [156]='PROF'
    [157]='WINCH'
    [158]='IO'
    [159]='PWR'
    [160]='UNUSED'
)'

# Choose a pseudo random separator character
# See https://github.com/ryanoasis/powerline-extra-symbols
declare -A SEPERATORS='(
    [0]=""
    [1]=""
    [2]=""
    [3]=""
    [4]=" "
    [5]=" "
    [6]=" "
    [7]=" "
)'
#
# Get current git branch
function parse_git_branch() {
    BRANCH=$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    [ ! "${BRANCH}" == "" ] && echo "\[\e[1;3${GS};4${G}m\]$(parse_git_dirty)\[\e[1;3${TEXT};4${G}m\]${BRANCH}" || echo ""
}

# Get git status
function parse_git_dirty {
    status=$(git status 2>/dev/null)
    modified=$(
        echo -n "${status}" | grep "modified:" &>/dev/null
        echo "$?"
    )
    untracked=$(
        echo -n "${status}" | grep "Untracked files" &>/dev/null
        echo "$?"
    )
    ahead=$(
        echo -n "${status}" | grep "Your branch is ahead of" &>/dev/null
        echo "$?"
    )
    newfile=$(
        echo -n "${status}" | grep "new file:" &>/dev/null
        echo "$?"
    )
    renamed=$(
        echo -n "${status}" | grep "renamed:" &>/dev/null
        echo "$?"
    )
    deleted=$(
        echo -n "${status}" | grep "deleted:" &>/dev/null
        echo "$?"
    )
    bits=''
    [ "${modified}" == "0" ] && bits="${bits} "
    [ "${newfile}" == "0" ] && bits="${bits} "
    [ "${deleted}" == "0" ] && bits="${bits} "
    [ "${renamed}" == "0" ] && bits="${bits} "
    [ "${untracked}" == "0" ] && bits="${bits}? "
    [ "${ahead}" == "0" ] && bits="${bits} "
    [ "${bits}" != "" ] && echo "${bits}" || echo ""
}
# Local connections can just use ALACRITTY_WINDOW_ID
if [[ -n $ALACRITTY_WINDOW_ID ]]; then
    # The last 4 bits are always 0, so drop them
    SEP_NUM=$(($ALACRITTY_WINDOW_ID >> 4))
# SSH connections can use PID stored in SSH_CONNECTION
elif [[ -n $SSH_CONNECTION ]]; then
    # Seems to always be even, so drop 1 bit
    SEP_NUM=$(($(echo $SSH_CONNECTION | cut -d ' ' -f 2) >> 1))
fi
# Just use the new last 4 bits to get a pseudo random number from 0-7
((SEP_NUM &= 7))
if [[ $SEP_NUM -gt 3 ]]; then
    SEP=${SEPERATORS["$SEP_NUM"]}
# First 4 separators look better with a trailing space
else
    SEP="${SEPERATORS["$SEP_NUM"]} "
fi

# Dark mode terminals should have black text on color; light mode has white
TEXT=0
BG=3
TERM_LIGHT=1
[[ -n $TERM_LIGHT ]] && TEXT=7 && BG=4

# Declare the S name (as used by `setterm`) and B for POSIX background colour
# Reference them later like: ${COLOURS["BLACK","S"]} or ${COLOURS["CYAN","B"]}
declare -A COLOURS='(
    [0,S]="default"
    [0,B]="\[\e[0m\]"
    [1,S]="red"
    [1,B]="\[\e[1;3${TEXT};41m\]"
    [2,S]="green"
    [2,B]="\[\e[1;3${TEXT};42m\]"
    [3,S]="yellow"
    [3,B]="\[\e[1;3${TEXT};43m\]"
    [4,S]="blue"
    [4,B]="\[\e[1;3${TEXT};44m\]"
    [5,S]="magenta"
    [5,B]="\[\e[1;3${TEXT};45m\]"
    [6,S]="cyan"
    [6,B]="\[\e[1;3${TEXT};46m\]"
    [7,S]="white"
    [7,B]="\[\e[1;30;47m\]"
)'

# Invert background and foreground in light mode
[[ $TEXT ]] && COLOURS[7,S]="black" && COLOURS[7,B]="\[\e[0m\]" && G=7 && GS=0
G=7
GS=0
# Force loading PROMPT_PATH on new shell
[[ $NEW_SHELL ]] && DIRCHANGED=1

# Record the time since previous command was run.
LAST_CMD_COUNT=$(history 1 | sed -r 's/([0-9]*) .*/\1/')
LAST_CMD_TIME=$(history 1 | sed -r 's/[0-9]* *([0-9]*).*/\1/')
if [[ "$LAST_CMD_COUNT" -ne "$LAST_HISTORY" ]]; then
    # Set by .bashrc. Indicate that no command has yet been run
    if [[ $NEW_SHELL ]]; then
        unset NEW_SHELL
    else
        RUNTIME=$(date +%s)
        RUNTIME=$((RUNTIME - LAST_CMD_TIME))
    fi
    LAST_HISTORY=$LAST_CMD_COUNT
fi

# Assign colour to each module
P="7"     # prompt default, white
ERROR="1" # prompt error
SIG="3"   # prompt signal
T="3"     # time, yellow
E="7"     # venv, white
C="0"     # chroot, default
U="2"     # user
R="1"     # root user
H="1"     # host (overwritten for distrobox and ssh)
B="4"     # distrobox
S="5"     # ssh
D="6"     # dir
G="7"     # git
GS="1"    # git sigils
GL="4"    # git langs

# Detect OS
HOSTOS="\\h"
[[ "$(hostname -s)" == "sericea" ]] && HOSTOS=" "
[[ "$(hostname -s)" == "fedora" ]] && HOSTOS=" "
[[ "$(hostname -s)" == "debian" ]] && HOSTOS=" "
[[ "$(hostname -s)" == "ubuntu" ]] && HOSTOS=" "
[[ "$(hostname -s)" == "fedora-coreos" ]] && HOSTOS=" "
[[ "$(hostname -s)" == "archlinux" ]] && HOSTOS=" "
[[ "$(uname -m)" == "aarch64" ]] && HOSTOS=""

# Explain prompt
[[ $1 && $1 != 'h' && $1 != '-h' && $1 != 'help' && $1 != '--help' && $1 != '?' ]] && echo "Invalid argument: $1" && exit
if [[ $1 ]]; then
  SIMPLIFIED=$(echo $PREVIOUS_PROMPT | sed -r 's|\\\[\\e\[[01](;3[0-9];4?[0-9])?m\\\]||g' | sed 's/\([🏠🖧]\)/\1 /g')
    SEP=${SEPERATORS["$SEP_NUM"]}
    USER=$(whoami)
    echo $SIMPLIFIED | sed "s/$SEP/ /g" | sed 's/\\n//'
    C=$P
    COUNT=0
    for i in $(echo $SIMPLIFIED | tr $SEP "\n"); do
        if [[ $i =~ '#' ]]; then
            echo "#  comment for safer copy/paste"
            if [[ $i =~ '' ]]; then
                setterm --foreground ${COLOURS[$SIG,"S"]}
                echo -n "  received signal: SIG"
            elif [[ $i =~ '' ]]; then
                echo -n "  long execution time: "
            elif [[ $i =~ '' ]]; then
                echo "HUH?"
                echo -n "  error code: "
            fi
        elif [[ $i =~ '' ]]; then
            echo "HUH?"
            echo -n "  error code: "
            NEXT=1
        elif [[ $i == '🖳 ' ]]; then
            C=$H
            setterm --foreground ${COLOURS[$C,"S"]}
            echo "$i running on host os"
            setterm --foreground default
            COUNT=$((COUNT-1))
        elif [[ $i == '🖧' ]]; then
            C=$B
            setterm --foreground ${COLOURS[$C,"S"]}
            echo "$i  running in SSH session"
            setterm --foreground default
            COUNT=$((COUNT-1))
        elif [[ $i == '' ]]; then
            C=$D
            setterm --foreground ${COLOURS[$C,"S"]}
            echo "$i  running in a distrobox"
            setterm --foreground default
            COUNT=$((COUNT-1))
        elif [[ "$i " == $HOSTOS ]]; then
            setterm --foreground ${COLOURS[$C,"S"]}
            echo "$i  OS ($(hostname -s))"
            setterm --foreground default
        elif [[ $i =~ '\t' ]]; then
            C=$T
            setterm --foreground ${COLOURS["3","S"]}
            echo "\\t time previous command ended"
            setterm --foreground default
        elif [[ $i == "$USER" ]]; then
            [[ "$USER" == "root" ]] && U=$R
            setterm --foreground ${COLOURS[$U,"S"]}
            [[ $i =~ "" ]] && echo "$i  user ($DEFAULT_USER)" || echo "$i user"
            setterm --foreground default
        elif [[ $COUNT -eq 5 ]]; then
            setterm --foreground ${COLOURS[$P,"S"]}
            echo "$i  path (position $COUNT)"
            setterm --foreground default
        elif [[ $COUNT -eq 6 ]]; then
            setterm --foreground ${COLOURS[$C,"S"]}
            echo "$i  git status (position $COUNT)"
            setterm --foreground default
        else
            echo $i
            setterm --foreground default
        fi
        COUNT=$((COUNT + 1))
    done
    exit
fi

# If directory was just changed detect local environment
if [[ $DIRCHANGED ]]; then
    # Reload Plenv version and PERL5LIB paths
    source ${HOME}/.dotfiles/bash/plenv-path.sh
    # If moved to the root of a git repository, print onefetch
    if [ -f "$PWD/.git/config" ]; then
        if [[ -z $GIT_REPO ]] || ! grep -q $GIT_REPO <<<$(pwd); then
            if [[ "$(which onefetch)" == "" ]]; then
                echo "This is a git directory, but you don't have 'onefetch' in your PATH"
            else
                onefetch
            fi
            echo -n "Fetching git status..."
            # Ignore submodules
            if [[ -e .gitmodules ]]; then
                IGNORE=''
                for module in $(grep path .gitmodules | cut -d '=' -f 2); do
                    IGNORE="$IGNORE -path ./$module -prune"
                done
                IGNORE="$IGNORE"
            fi
            GIT_LANGS="\[\e[1;3${GL};4${G}m\]"
            [[ "$(find ./ $IGNORE -readable -name '*.c')" ]] && GIT_LANGS="${GIT_LANGS}󰙱"
            [[ "$(find ./ $IGNORE -readable -name '*.cpp')" ]] && GIT_LANGS="${GIT_LANGS}󰙲 "
            [[ "$(find ./ $IGNORE -readable -name '*.cs')" ]] && GIT_LANGS="${GIT_LANGS}󰌛 "
            [[ "$(find ./ $IGNORE -readable -name '*.f[079][0357]')" ]] && GIT_LANGS="${GIT_LANGS}󱈚 "
            [[ "$(find ./ $IGNORE -readable -name '*.go')" ]] && GIT_LANGS="${GIT_LANGS}󰟓 "
            [[ "$(find ./ $IGNORE -readable -name '*.hs')" ]] || [[ "$(find ./ $IGNORE -readable -name '*.lhs')" ]] && GIT_LANGS="${GIT_LANGS}󰲒 "
            [[ "$(find ./ $IGNORE -readable -name '*.html')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.kt')" ]] || [[ "$(find ./ $IGNORE -readable -name '*.kt[sm]')" ]] && GIT_LANGS="${GIT_LANGS}󱈙 "
            [[ "$(find ./ $IGNORE -readable -name '*.js')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.css')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.lua')" ]] && GIT_LANGS="${GIT_LANGS}󰢱 "
            [[ "$(find ./ $IGNORE -readable -name '*.java')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.php')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.p[lm]')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.py')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.rb')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.rs')" ]] && GIT_LANGS="${GIT_LANGS}"
            [[ "$(find ./ $IGNORE -readable -name '*.vim')" ]] && GIT_LANGS="${GIT_LANGS} "
            [[ "$(find ./ $IGNORE -readable -name '*.sqlite')" ]] && GIT_LANGS="${GIT_LANGS}"
            [[ "$(find ./ $IGNORE -readable -name '*.md')" ]] && GIT_LANGS="${GIT_LANGS}󰍔 "
            if [[ $GIT_LANGS == "\[\e[1;3${GL};4${G}m\]" ]]; then
                unset GIT_LANGS
            else
                export GIT_LANGS=" $GIT_LANGS"
            fi
            echo -n -e "\r"
        fi
        export GIT_REPO=$PWD
    fi
    if [[ $GIT_REPO ]] && ! grep -q $GIT_REPO <<<$(pwd); then
        unset GIT_REPO GIT_LANGS
    fi
    unset DIRCHANGED
    PROMPT_PATH="$(echo $PWD | sed -r "s|$HOME| |")/"
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/android/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/build/|/󰣪 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/coding/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/documents/|/󰧮 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/downloads/|/󰇚 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/exercism/|/{}/|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/games/|/󰊴 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/music/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/nc/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/pictures/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/images/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/videos/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/wallpapers/|/󰸉 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/c/|/󰙱/|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/cpp/|/󰙲 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/cs/|/󰌛 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/fortran/|/󱈚/|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/go/|/󰟓 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/haskell/|/󰲒 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/html/|//|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/js/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/css/|//|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/kotlin/|/󱈙 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/lua/|/󰢱 /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/java/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/perl/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/php/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/python/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/ruby/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/rust/|//|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/vim/|/ /|i")
    PROMPT_PATH=$(echo $PROMPT_PATH | sed -r "s|/$||")
fi

# Opening # so that PS1 gets interpretted as a comment if pasted into a terminal or script
if [[ $RET -gt 128 ]]; then
    PS1="${COLOURS["$SIG","B"]}# ${SIGNALS["$RET"]}"
    LASTB=$SIG
elif [[ $RET -gt 0 ]]; then
    PS1="${COLOURS["$ERROR","B"]}# $RET"
    LASTB=$ERROR
else
    PS1="\[\e[0;3${TEXT};4${P}m\]#"
    LASTB=$P
fi

# Ignore long runtime for su, SSH, and nested Bash shells
if [[ -n $RUNTIME ]] && [[ "$RUNTIME" =~ "sudo su" ]] && [[ "$RUNTIME" =~ "ssh " ]] && [[ "$RUNTIME" =~ "bash " ]]; then
    # Format runtime to HH:MM:SS, MM:SS, or SSs
    if [[ $RUNTIME -gt 3600 ]]; then
        HOURS=$((RUNTIME / 3600))
        RUNTIME=$((RUNTIME - (HOURS * 3600)))
        MINUTES=$((RUNTIME / 60))
        RUNTIME=$((RUNTIME - (MINUTES * 60)))
        PS1="${PS1} $(printf "%02d:%02d:%02d" $HOURS $MINUTES $RUNTIME)"
    elif [[ $RUNTIME -gt 60 ]]; then
        MINUTES=$((RUNTIME / 60))
        RUNTIME=$((RUNTIME - (MINUTES * 60)))
        PS1="${PS1} $(printf "%02d:%02d" $MINUTES $RUNTIME)"
    elif [[ $RUNTIME -gt 10 ]]; then
        PS1="${PS1} $(printf "%02ds" $RUNTIME)"
    fi
fi

# Sigil to indicate host, distrobox or ssh. Store HC so that host matches connection type
if [ -f "/run/.containerenv" ]; then
    H=$B
    PS1="${PS1}\[\e[0;${BG}${LASTB};4${H}m\]"${SEP}"${COLOURS["$H","B"]} "
elif [[ -z $SSH_CLIENT ]]; then
    PS1="${PS1}\[\e[0;${BG}${LASTB};4${H}m\]"${SEP}"${COLOURS["$H","B"]}🖳 "
else
    H=$S
    PS1="${PS1}\[\e[0;${BG}${LASTB};4${H}m\]"${SEP}"${COLOURS["$H","B"]}🖧 "
fi

# OS
PS1="${PS1}$HOSTOS\[\e[0;3${TEXT};4${H}m\]"
LASTB=$H

# Time
PS1="${PS1}\[\e[0;3${LASTB};4${T}m\]"${SEP}
PS1="${PS1}${COLOURS["$T","B"]}\\t"
LASTB=$T

# Python venv
if [ "$VIRTUAL_ENV" ]; then
    VENV="${VIRTUAL_ENV##*/}"
    VENV=$(echo "$VENV" | sed -r 's/.*/[\0]/')
    [[ $1 ]] && setterm --foreground ${COLOURS["$E","S"]} && echo "venv" && setterm --foreground default
    PS1=${PS1}\[\e[0
    3${LASTB}
    4${E}m\]${SEP}${COLOURS["$E","B"]}${VENV}
    LASTB=$E
fi

# Debian Chroot
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    [[ $1 ]] && setterm --foreground ${COLOURS["$C","S"]} && echo "debian chroot" && setterm --foreground default
    PS1="${PS1}\[\e[0;3${LASTB};4${C}m\]${SEP}"${COLOURS["$C","B"]}"<$(cat /etc/debian_chroot)>"
    LASTB=$C
fi

# User
USR=$(whoami)
[[ "$USR" == 'root' ]] && U=$R
[[ "$USR" == "$DEFAULT_USER" ]] && USR=" "
PS1="${PS1}\[\e[0;3${LASTB};4${U}m\]"${SEP}"${COLOURS["$U","B"]}$USR\[\e[0;3${TEXT};4${U}m\]"
LASTB=$U

# Dir
PS1="${PS1}\[\e[0;3${LASTB};4${D}m\]"${SEP}"${COLOURS["$D","B"]}${PROMPT_PATH}"
LASTB=$D

# Git
GIT_DIRTY=$(parse_git_branch)
if [[ ! -z $GIT_LANGS ]] || [[ ! -z $GIT_DIRTY ]]; then
    [[ $1 ]] && setterm --foreground ${COLOURS["$G","S"]} && echo "git branch status" && setterm --foreground default
    PS1="${PS1}\[\e[0;3${LASTB};4${G}m\]${SEP}${GIT_DIRTY}${GIT_LANGS}"
    LASTB=$G
fi

# \n - start input on new line, again to support copy-paste into bash script
PS1="${PS1}\[\e[0;3${LASTB};1m\]"${SEP}"\[\e[0m\]\n"

export PS1
export PREVIOUS_PROMPT=$PS1
unset RUNTIME

# Trap next command to be used by next iteration of prompt
trap 'LAST_CMD=$this_command; this_command=$BASH_COMMAND' DEBUG
