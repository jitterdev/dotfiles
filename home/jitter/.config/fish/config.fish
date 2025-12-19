alias dot='git --git-dir=$HOME/.dotfiles --work-tree=/'
alias fullfetch='fastfetch --config full'

set -gx EDITOR nano
set -gx VISUAL nano
set -gx PAGER moor

set -x FZF_DEFAULT_OPTS "--preview '$HOME/.config/fish/functions/fzf_preview.sh {}'"

set -x FZF_DEFAULT_OPTS "--preview '$HOME/.config/fish/functions/fzf_preview.sh {}' --bind 'ctrl-c:execute(kitty +kitten icat --clear)+abort'"
set fzf_preview_file_cmd ~/.config/fish/functions/fzf_preview.sh
set fzf_preview_dir_cmd ~/.config/fish/functions/fzf_preview_dir.sh

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
