#!/bin/bash

## Variables

IS_THREADED=0
DELAY=0.5
LIST_PATCHES=0
PATCH_URI="https://dwm.suckless.org/patches"

## Functions

usage()
{
    echo "Usage: suckless-patches.sh [options...]"
    echo " -t  Spawn every patch request in a separate thread."
    echo " -d  Only in threaded mode. The delay between the creation of a new thread. (Default: 1)"
    echo " -v  Version information."
    echo " -h  Displays this help dialog."
}

parse()
{
    patch=$1
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
        if [ "${diff##*.}" == "diff" ] && ! echo "$diff" | grep "/"; then
            echo "$PATCH_URI/$patch/$diff"
        fi
    done

}

## Option Parsing

while getopts ":vthld:" opt; do
    case "${opt}" in
        t)
            IS_THREADED=1
            ;;
        d)
            re='^[0-9]+([.][0-9]+)?$' 
            if [[ $OPTARG =~ $re ]]; then
                IS_THREADED=1
                DELAY="$OPTARG"
            else
                echo "Error: '$OPTARG' is not a positive number."
                exit
            fi
            ;;
        l)
            LIST_PATCHES=1
            ;;
        v)
            echo "suckless-patches.sh 1.0.0"
            exit
            ;;

        h)
            usage
            exit
            ;;
        \?)
            echo "Error: unknown option '$OPTARG'."
            usage
            exit
            ;;
        :)
            echo "Error: option '$OPTARG' requires an argument."
            exit
    esac
done

## Main

PATCHES=( $(curl --silent "$PATCH_URI/" |
            grep "//dwm.suckless.org/patches/" |
            grep -v "<b>patches/</b>" |
            grep -oP '(?<=<li><a href="//dwm.suckless.org/patches/).*(?=/">)'
        ) )

if [ "$LIST_PATCHES" -eq 1 ]; then
    for patch in "${PATCHES[@]}"
    do
        echo "$patch"
    done
    exit
fi

for patch in "${PATCHES[@]}"
do
    if [ "$IS_THREADED" -eq 1 ]; then
        parse $patch &
        sleep $DELAY
    else
        parse $patch
    fi
done
 
