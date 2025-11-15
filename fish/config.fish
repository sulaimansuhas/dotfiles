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

function jk_escape
    set fish_bind_mode default
    commandline -f repaint
end

function reload
    source ~/.config/fish/config.fish
    echo "Fish config reloaded! 🐟"
end

bind -M insert jk jk_escape
bind -M insert \cr history-pager
bind -M default \cr history-pager
bind -M insert \cp history-search-backward
bind -M default \cp history-search-backward
bind -M insert \cn history-search-forward
bind -M default \cn history-search-forward

#think of a better setup for these custom scripts
if test -f ~/.config/customFish/main.fish
    source ~/.config/customFish/main.fish
end
