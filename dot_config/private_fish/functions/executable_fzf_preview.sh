#!/bin/bash
file="$1"
mime=$(file --mime-type -b "$file")

# Clear previous image (and suppress errors for when we're not viewing an image)
kitty +kitten icat --clear --transfer-mode=memory 2>/dev/null

case "$mime" in
    image/*)
        kitty +kitten icat --transfer-mode=memory --stdin=no \
            --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" "$file"
        ;;
    video/*)
        ffmpegthumbnailer -i "$file" -o /tmp/fzf-thumb.png -s 0 2>/dev/null \
            && kitty +kitten icat --transfer-mode=memory --stdin=no \
                --place="${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0" /tmp/fzf-thumb.png
        ;;
    application/pdf)
        pdftotext -l 5 -nopgbrk "$file" - 2>/dev/null
        ;;
    application/zip|application/gzip|application/x-tar)
        atool -l "$file" 2>/dev/null
        ;;
    *)
        bat --style=numbers --color=always "$file" 2>/dev/null || cat "$file"
        ;;
esac