#!/bin/bash
dir="$1"

# Clear previous image
kitty +kitten icat --clear --transfer-mode=memory 2>/dev/null

# Show directory contents
eza --all --color=always "$dir"
