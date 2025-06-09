#!/bin/bash

if [[ -n $1 ]]; then
    if [[ $1 == '-d' ]]; then
        DRY=1
    else
        echo "Invalid argument $1"
        exit
    fi
fi

function get_lincoln() {
    local DIR=$1
    local ABS=$(realpath $DIR)
    local REL=$(echo $DIR | sed "s,^./,,")
    echo "Looking for files in $ABS"
    for ITEM in $(find $DIR -maxdepth 1); do
        [[ $ITEM == $DIR ]] && continue
        ITEM=$(echo $ITEM | sed "s,^$DIR,," | sed "s,^/,,")
        [[ $ITEM == '.linkignore' ]] && continue
        if [[ -e $ABS/.linkignore ]]; then
            if grep -q $ITEM <<< $(cat $ABS/.linkignore); then
                setterm --foreground yellow
                echo "$ITEM is in $ABS/.linkignore"
                setterm --foreground default
                continue
            fi
        fi
        if [[ -e $HOME/$REL/$ITEM ]]; then
            if [[ -L $HOME/$REL/$ITEM ]]; then
                setterm --foreground green
                echo "Link for $ABS/$ITEM already exists"
                setterm --foreground default
            elif [[ -d $HOME/$REL/$ITEM ]]; then
                [[ $REL ]] && get_lincoln "$REL/$ITEM" || get_lincoln "$ITEM"
            else
                echo "Backing up existing $ITEM"
                if [ $REL ]; then
                    echo "mv $HOME/$REL/$ITEM $HOME/$REL/$ITEM.bk"
                    [ $DRY ] || mv $HOME/$REL/$ITEM $HOME/$REL/$ITEM.bk
                    echo "Creating new link $ABS/$ITEM to $HOME/$REL/$ITEM"
                    [ $DRY ] || ln -s $ABS/$ITEM $HOME/$REL/$ITEM
                else
                    echo "mv $HOME/$ITEM $HOME/$ITEM.bk"
                    [ $DRY ] || mv $HOME/$ITEM $HOME/$ITEM.bk
                    echo "Creating new link $ABS/$ITEM to $HOME/$ITEM"
                    [ $DRY ] || ln -s $ABS/$ITEM $HOME/$ITEM
                fi
            fi
        else
            if [ $REL ]; then
                setterm --foreground red
                echo "Linking $HOME/$REL/$ITEM to $ABS/$ITEM"
                [ $DRY ] || ln -s $ABS/$ITEM $HOME/$REL/$ITEM
                setterm --foreground default
            else
                setterm --foreground red
                echo "Linking $HOME/$ITEM to $ABS/$ITEM"
                [ $DRY ] || ln -s $ABS/$ITEM $HOME/$ITEM
                setterm --foreground default
            fi
        fi
    done
    echo "Done $DIR"
}

ROOT=$(echo $0 | sed 's/symlink.sh//')
get_lincoln $ROOT
