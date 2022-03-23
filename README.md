# dwm Patch Fetch

This is just a simple script which fetches all of the patches from [https://dwm.suckless.org/patches/](https://dwm.suckless.org/patches/) and parses each page for a description and a patch name.

It is recommended that you save the output of this script to a file and parse it from there since every diff and description must be individually requested and parsed, making the script slow and unncessarily spam the suckless servers. There is a built in threaded mode and delay option which should be used with discretion. My intention is not to DDoS suckless, so do set the delay option to something other than 0 please!

## Features

- Listing the URLS of all of the diffs
- Listing all of the patches

## Dependencies

- bash (obviously)
- html-xml-utils
- curl
- grep

## Why make this?

Good question. The main reason I made this was becuase I was curious which version of dwm was more widely supported, and which patches did in fact support it. Using my script and the handy math function from my favorite shell `fish` I found that *70.2% of patches have explicit support for 6.2*.

```fish
math (./dwm-patch-fetch.sh | grep "6.2" | wc -l)/(./dwm-patch-fetch.sh -l | wc -l)
```

The reason I say 'explicit' is because some patches aren't named `mycoolpatch-6.2.diff` so its hard to really know an exact number through scripting, but we can safely say that over 70% of patches work with 6.2. 

If you're curious about what percentage of patches explicitly support 6.3, you should download the script and find out! I can't do all the work.

