#!/usr/bin/env fish
if not command -v nvim  > /dev/null
    if DETECTED_OS = "OSX"
        brew install nvim
    else
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        sudo rm -rf /opt/nvim
        sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    end
    echo "✅ Neovim installed"
else
    echo "✅ Neovim already installed"
end

set has_config (test -d ~/.config/nvim; echo $status)

if test $has_config -eq 0 
    echo "⚠️  Existing nvim configuration found"
    
    if test $has_config -eq 0
        echo "   • ~/.config/nvim"
    end
    
    while true
        read -P "Backup existing nvim config? (y(es)/n(o)/k(eep)): " -n 1 backup_choice
        echo
        
        switch $backup_choice
            case "y" "Y"
                set timestamp (date +%s)
                mv ~/.config/nvim ~/.config/nvim.backup-$timestamp
                echo "📦 Backup complete"
                break
            case "n" "N" ""
                rm ~/.config/nvim
                echo "🗑️  Existing config removed"
                break
            case "k" "K" ""
                echo "Keeping Existing config"
                exit 0
            case "*"
                echo "❌ Please enter 'y' or 'n' or 'k'"
        end
    end
end

ln -s $PWD/nvim/ ~/.config/nvim
echo "✅ Neovim config linked"

# Create symlink to .config/nvim
echo "🔗 Linking nvim configuration..."
if test -d nvim 
    if ln -s (realpath nvim/) ~/.config/nvim/
        echo "✅ nvim config linked successfully"
    else
        echo "❌ Failed to link nvim config"
        exit 1
    end
else
    echo "❌ nvim/ found"
    exit 1
end



