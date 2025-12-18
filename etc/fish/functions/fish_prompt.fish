# kitsune

function fish_prompt
  if not set -q __fish_prompt_hostname
    set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
  end

  set -l normal (set_color normal)
  set -l brackets (set_color brwhite)
  set -l separator (set_color brblack)
  set -l color_user (set_color blue)
  set -l color_host (set_color b4befe)
  set -l color_dir (set_color f5c2e7)

  set -g __fish_git_prompt_showdirtystate true
  set -g __fish_git_prompt_showuntrackedfiles true
  set -g __fish_git_prompt_showstashstate true
  set -g __fish_git_prompt_show_informative_status true

  set -g __fish_git_prompt_color_flags f38ba8 # Red
  set -g __fish_git_prompt_color_prefix 89dceb # Sky
  set -g __fish_git_prompt_color_suffix 89dceb # Sky

  set -l symbol '$'
  if fish_is_root_user
      set symbol '#'
  end

  echo -n $brackets'┌['$color_user$USER$separator'@'$color_host$__fish_prompt_hostname$brackets']'$separator'-'$brackets'('$color_dir(prompt_pwd)$brackets')'
  __fish_git_prompt "-[git://%s]-"
  echo

  echo -n $brackets'└'$symbol$normal

  echo -n " "
end

function transient_prompt_func
    set --local color green
    if test $transient_pipestatus[-1] -ne 0
        set color red
    end
    echo -en (set_color $color)"❯ "(set_color normal)
end
