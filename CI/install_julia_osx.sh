#!/bin/bash
# Install julia into ~/julia on OSX
if [[ "$JULIAVERSION" == "releases" ]]; then
    wget -O julia.dmg http://status.julialang.org/download/osx10.7+
fi
if [[ "$JULIAVERSION" == "nightlies" ]]; then
    wget -O julia.dmg http://status.julialang.org/stable/osx10.7+
fi

hdiutil mount julia.dmg

cp -Ra /Volumes/Julia/*.app/Contents/Resources/julia ~
export PATH="$PATH:$(echo ~)/julia/bin"
