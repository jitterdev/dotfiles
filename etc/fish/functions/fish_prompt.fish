status is-interactive || exit

# Async Git

set --global _git_info _git_info_$fish_pid

function $_git_info --on-variable $_git_info
    commandline --function repaint
end

function _git_prompt_async --on-event fish_prompt
    command kill $_git_last_pid 2>/dev/null

    set -l git_dir (command git rev-parse --git-dir 2>/dev/null)
    if test -z "$git_dir"
        set --universal $_git_info ""
        return
    end

    fish --private --command "
        set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
        
        if test -z \"\$branch\"
            set branch '('(command git rev-parse --short HEAD 2>/dev/null)')'
        end

        set -l staged (command git diff --cached --numstat 2>/dev/null | count)
        set -l modified (command git diff --numstat 2>/dev/null | count)
        set -l untracked (command git ls-files --others --exclude-standard 2>/dev/null | count)
        set -l stash (command git stash list 2>/dev/null | count)

        set -l flags ''
        test \$staged -gt 0 && set flags \"\$flags●\$staged\"
        test \$modified -gt 0 && set flags \"\$flags✚\$modified\"
        test \$untracked -gt 0 && set flags \"\$flags…\$untracked\"
        test \$stash -gt 0 && set flags \"\$flags⚑\$stash\"

        set -l upstream ''
        command git rev-list --count --left-right @{upstream}...@ 2>/dev/null | read -l behind ahead
        
        if test -n \"\$ahead\" -a -n \"\$behind\"
            if test \"\$ahead\" != 0 -a \"\$behind\" != 0
                set upstream \"↑\$ahead↓\$behind\"
            else if test \"\$ahead\" != 0
                set upstream \"↑\$ahead\"
            else if test \"\$behind\" != 0
                set upstream \"↓\$behind\"
            end
        end

        test -n \"\$flags\" && set flags \"|\$flags\"
        test -n \"\$upstream\" && set flags \"\$flags\$upstream\"

        set --universal $_git_info \"\$branch\$flags\"
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
    set -l color_user (set_color fab387)
    set -l color_host (set_color yellow)
    set -l color_dir (set_color f5c2e7)
    set -l color_git_bracket (set_color 89dceb)
    set -l color_branch (set_color normal)
    set -l color_flags (set_color brred)
    set -l normal (set_color normal)

    set -l symbol '$'
    fish_is_root_user && set symbol '#'

    # Line 1
    echo -n $brackets'┌['$color_user$USER$separator'@'$color_host$__fish_prompt_hostname$brackets']'$separator'-'$brackets'('$color_dir(prompt_pwd)$brackets')'

    # Git info
    set -l info $$_git_info
    if test -n "$info"
        set -l parts (string split '|' -- $info)
        set -l branch $parts[1]
        set -l flags ""
        test (count $parts) -gt 1 && set flags $parts[2]
        
        echo -n $color_git_bracket'-['$color_branch$branch
        if test -n "$flags"
            echo -n $normal'|'$color_flags$flags
        end
        echo -n $color_git_bracket']-'
    end

    echo
    echo -n $brackets'└'$symbol$normal' '
end

function transient_prompt_func
    set -l color green
    test $transient_pipestatus[-1] -ne 0 && set color red
    echo -n (set_color $color)'❯ '(set_color normal)
end
