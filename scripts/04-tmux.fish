#!/usr/bin/env fish
# scripts/04-tmux-setup.fish (simplified)

echo "📺 Setting up tmux..."
if not command -v tmux >/dev/null
    echo "📦 Installing tmux..."
    
    switch $DETECTED_OS
        case "macos"
            brew install tmux
        case "linux"
            if command -v apt >/dev/null
                sudo apt update && sudo apt install -y tmux
            else if command -v yum >/dev/null
                sudo yum install -y tmux
            else if command -v pacman >/dev/null
                sudo pacman -S tmux
            else
                echo "❌ Please install tmux manually"
                exit 1
            end
        case "*"
            echo "❌ Unsupported OS: $DETECTED_OS"
            exit 1
    end
    echo "✅ tmux installed"
else
    echo "✅ tmux already installed"
end

# Check for existing tmux files
set has_config (test -f ~/.tmux.conf; echo $status)
set has_dir (test -d ~/.tmux; echo $status)

if test $has_config -eq 0 -o $has_dir -eq 0
    echo "⚠️  Existing tmux configuration found"
    
    if test $has_config -eq 0
        echo "   • ~/.tmux.conf"
    end
    if test $has_dir -eq 0
        echo "   • ~/.tmux/ directory"
    end
    
    while true
        read -P "Backup existing tmux config? (y/N): " -n 1 backup_choice
        echo
        
        switch $backup_choice
            case "y" "Y"
                set timestamp (date +%s)
                test $has_config -eq 0 && mv ~/.tmux.conf ~/.tmux.conf.backup-$timestamp
                test $has_dir -eq 0 && mv ~/.tmux ~/.tmux.backup-$timestamp
                echo "📦 Backup complete"
                break
            case "n" "N" ""
                test $has_config -eq 0 && rm ~/.tmux.conf
                test $has_dir -eq 0 && rm -rf ~/.tmux
                echo "🗑️  Existing config removed"
                break
            case "*"
                echo "❌ Please enter 'y' or 'n'"
        end
    end
end

# Create symlink to tmux.conf
echo "🔗 Linking tmux configuration..."
if test -f tmux/tmux.conf
    if ln -s (realpath tmux/tmux.conf) ~/.tmux.conf
        echo "✅ tmux config linked successfully"
    else
        echo "❌ Failed to link tmux config"
        exit 1
    end
else
    echo "❌ tmux/tmux.conf not found"
    exit 1
end

# Install TPM (Tmux Plugin Manager) if tmux.conf uses plugins
if grep -q "set -g @plugin" tmux/tmux.conf
    echo "🔌 Installing TPM (Tmux Plugin Manager)..."
    
    # Clone TPM (will create ~/.tmux/plugins/tpm)
    mkdir -p ~/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    
    echo "✅ TPM installed"
    echo "💡 Start tmux and press prefix + I to install plugins"
    echo "💡 Default prefix is Ctrl-b (unless changed in config)"
else
    echo "ℹ️  No plugins detected in tmux.conf"
end

# Check tmux version
set tmux_version (tmux -V | cut -d' ' -f2)
echo "📊 tmux version: $tmux_version"

echo "🚀 tmux setup complete!"
echo "💡 Start tmux with: tmux"
echo "💡 Reload config: tmux source ~/.tmux.conf"

