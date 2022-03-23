#!/bin/bash

PATCH_URI="https://dwm.suckless.org/patches"

## Get a list of patches
PATCHES=( $(curl --silent "$PATCH_URI/" |
            grep "//dwm.suckless.org/patches/" |
            grep -v "<b>patches/</b>" |
            grep -oP '(?<=<li><a href="//dwm.suckless.org/patches/).*(?=/">)'
        ) )

for patch in "${PATCHES[@]}"
do
    PATCH_HTML="$(curl --silent "$PATCH_URI/$patch/")"
    DESCRIPTION="$(echo "$PATCH_HTML" | sed -n '/<h2>Description<\/h2>/,/<h2>Download<\/h2>/p' | sed '$d' | sed '1,1d' | hxselect -c -s '\n' "p")"

    if echo "$PATCH_HTML" | grep "<h2>Related Projects</h2>" &> /dev/null; then
        DIFFS=($(echo "$PATCH_HTML" | sed -n '/<h2>Download<\/h2>/,/<h2>Related Projects<\/h2>/p' | sed '$d' | sed '1,1d' | hxwls))
    else
        if echo "$PATCH_HTML" | grep "<h2>Authors</h2>" &> /dev/null; then
            DIFFS=($(echo "$PATCH_HTML" | sed -n '/<h2>Download<\/h2>/,/<h2>Authors<\/h2>/p' | sed '$d' | sed '1,1d' | hxwls))
        else
            DIFFS=($(echo "$PATCH_HTML" | sed -n '/<h2>Download<\/h2>/,/<h2>Author<\/h2>/p' | sed '$d' | sed '1,1d' | hxwls))
        fi
    fi

    for diff in "${DIFFS[@]}"
    do
        if [ "${diff##*.}" == "diff" ]; then
            chromium "$PATCH_URI/$patch/$diff"
        fi
    done

done
 
