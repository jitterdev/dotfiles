status is-interactive || exit

# Async Git

set --global _git_info _git_info_$fish_pid

function $_git_info --on-variable $_git_info
    commandline --function repaint
end

function _git_prompt_async --on-event fish_prompt
    command kill $_git_last_pid 2>/dev/null

    # Check if in git repo
    set -l git_dir (command git rev-parse --git-dir 2>/dev/null)
    if test -z "$git_dir"
        set --universal $_git_info ""
        return
    end

    fish --private --command "
        set -l branch (
            command git symbolic-ref --short HEAD 2>/dev/null ||
            command git describe --tags --exact-match HEAD 2>/dev/null ||
            command git rev-parse --short HEAD 2>/dev/null |
                string replace --regex -- '(.+)' '@\$1'
        )

        set -l dirty
        set -l untracked
        set -l stash

        command git diff --quiet HEAD 2>/dev/null || set dirty '!'
        test -n \"\$(command git ls-files --others --exclude-standard 2>/dev/null)\" && set untracked '?'
        command git rev-parse --verify refs/stash &>/dev/null && set stash '\$'

        set -l upstream
        command git rev-list --count --left-right @{upstream}...@ 2>/dev/null | read -l behind ahead
        
        if test -n \"\$ahead\" -a -n \"\$behind\"
            if test \"\$ahead\" != 0 -a \"\$behind\" != 0
                set upstream \" ↑\$ahead ↓\$behind\"
            else if test \"\$ahead\" != 0
                set upstream \" ↑\$ahead\"
            else if test \"\$behind\" != 0
                set upstream \" ↓\$behind\"
            end
        end

        set -l flags \"\$dirty\"\"\$untracked\"\"\$stash\"
        test -n \"\$flags\" && set flags \" \$flags\"

        set --universal $_git_info \"\$branch\$flags\$upstream\"
    " &

    set --global _git_last_pid $last_pid
end

function _git_cleanup --on-event fish_exit
    set --erase $_git_info
end

# Prompt

set -g __fish_prompt_hostname (hostname | cut -d . -f 1)

function fish_prompt
    set -l brackets (set_color brwhite)
    set -l separator (set_color brblack)
    set -l color_user (set_color blue)
    set -l color_host (set_color b4befe)
    set -l color_dir (set_color f5c2e7)
    set -l color_git (set_color 89dceb)
    set -l color_flags (set_color f38ba8)
    set -l normal (set_color normal)

    set -l symbol '$'
    fish_is_root_user && set symbol '#'

    # Line 1
    echo -n $brackets'┌['$color_user$USER$separator'@'$color_host$__fish_prompt_hostname$brackets']'$separator'-'$brackets'('$color_dir(prompt_pwd)$brackets')'

    # Git info
    set -l info $$_git_info
    if test -n "$info"
        set -l branch (string split ' ' -- $info)[1]
        set -l rest (string replace -- "$branch" '' "$info")
        echo -n $separator'-'$brackets'['$color_git$branch$color_flags$rest$brackets']'
    end

    echo
    echo -n $brackets'└'$symbol$normal' '
end

function transient_prompt_func
    set -l color green
    test $transient_pipestatus[-1] -ne 0 && set color red
    echo -n (set_color $color)'❯ '(set_color normal)
end