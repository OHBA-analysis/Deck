#!/bin/bash

HERE=$(dirname "$BASH_SOURCE")
fail() {
    echo "$*"
    exit 1;
}

Target="GUI Layout Toolbox 2.3.3.mltbx"
Temporary=$HERE/temp

[ -d "$HERE/layout" ] && fail "Already extracted"
[ -d "$HERE/layoutdoc" ] && fail "Already extracted"

[ -d "$Temporary" ] && rm -rf "$Temporary"
mkdir "$Temporary" || fail "Failed to create temporary folder."
unzip "$HERE/$Target" -d "$Temporary" || fail "Could not extract toolbox contents."

for d in layout layoutdoc; do 
    mv -vn "$Temporary/fsroot/$d" "$HERE"
done

