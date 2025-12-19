## Greeting
function fish_greeting
    command -sq fastfetch; and fastfetch
end

## Man page formatting
set -gx MANROFFOPT "-c"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx SYSTEMD_COLORS 1
set -gx SYSTEMD_PAGER "moor"
set -gx SYSTEMD_PAGERSECURE true

## done (handled by fisher, but vars are universal)
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Apply fish-compatible profile
if test -f ~/.fish_profile
    source ~/.fish_profile
end

## PATH management
if test -d ~/.local/bin
    contains -- ~/.local/bin $PATH; or set -p PATH ~/.local/bin
end

if test -d ~/Applications/depot_tools
    contains -- ~/Applications/depot_tools $PATH; or set -p PATH ~/Applications/depot_tools
end

## bang-bang (!! and !$)
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if test "$fish_key_bindings" = fish_vi_key_bindings
    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

## History with timestamps
function history
    builtin history --show-time='%F %T '
end

## Utility functions
function backup --argument filename
    cp $filename $filename.bak
end

function copy
    set count (count $argv)
    if test "$count" = 2; and test -d "$argv[1]"
        set from (string trim-right / -- $argv[1])
        cp -r $from $argv[2]
    else
        cp $argv
    end
end

## Aliases
alias ls='eza -al --color=always --group-directories-first --icons'
alias la='eza -a --color=always --group-directories-first --icons'
alias ll='eza -l --color=always --group-directories-first --icons'
alias lt='eza -aT --color=always --group-directories-first --icons'
alias l.="eza -a | grep -e '^\.'"

alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias grep='grep --color=auto'
alias hw='hwinfo --short'
alias big="expac -H M '%m\t%n' | sort -h | nl"
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'
alias update='sudo pacman -Syu'
alias mirror="sudo cachyos-rate-mirrors"
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias jctl="journalctl -p 3 -xb"
alias dm='sudo dmesg --human --color=always | moor'

alias please='sudo'
alias tb='nc termbin.com 9999'

alias cat='bat -pp'
alias pat='bat -p'