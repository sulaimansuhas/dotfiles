# Vi mode (similar to your zsh setup)
fish_vi_key_bindings

# Set vi mode indicator
function fish_mode_prompt
    switch $fish_bind_mode
        case default
            set_color red
            echo '[CMD] '
        case insert
            set_color green  
            echo '[INS] '
        case visual
            set_color yellow
            echo '[VIS] '
    end
    set_color normal
end

function jj_escape
    set fish_bind_mode default
    commandline -f repaint
end

function reload
    source ~/.config/fish/config.fish
    echo "Fish config reloaded! 🐟"
end

# Custom prompt
function fish_prompt
    set_color yellow
    date '+%H:%M:%S'
    set_color normal
    echo -n ' '
    
    set_color cyan
    echo -n $USER@(hostname)
    set_color normal
    echo -n ' '
    
    set_color blue
    echo -n (prompt_pwd)
    set_color normal
    
    # Git info (fish has this built-in!)
    fish_git_prompt
    
    echo
    set_color green
    echo -n '❯ '
    set_color normal
end

# Git prompt configuration
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_color_branch magenta
set -g __fish_git_prompt_color_dirty red
set -g __fish_git_prompt_color_staged green

bind -M insert jj jj_escape
bind -M insert \cr history-pager
bind -M default \cr history-pager
bind -M insert \cp history-search-backward
bind -M default \cp history-search-backward


