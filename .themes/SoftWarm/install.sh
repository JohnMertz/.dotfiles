#!/usr/bin/env bash

TARGET="$HOME/.local/share/themes/SoftWarm"

mkdir -p "$TARGET"
cp -r ./* "$TARGET"

echo "Installed SoftWarm theme."
echo "Set it with: export GTK_THEME=SoftWarm"
