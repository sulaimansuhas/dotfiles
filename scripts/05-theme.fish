#!/usr/bin/env fish
# scripts/05-theme.fish
# Install the theme-toggle script and seed the shared mode file.

echo "🎨 Setting up theme toggle..."

mkdir -p ~/.config
if not test -f ~/.config/theme-mode
    echo "dark" > ~/.config/theme-mode
    echo "✅ Initialized ~/.config/theme-mode (dark)"
else
    echo "✅ ~/.config/theme-mode exists ("(cat ~/.config/theme-mode)")"
end

if not test -f bin/theme-toggle
    echo "❌ bin/theme-toggle not found in repo"
    exit 1
end

chmod +x bin/theme-toggle

mkdir -p ~/.local/bin
set src (realpath bin/theme-toggle)
set dst ~/.local/bin/theme-toggle

if test -L $dst
    rm $dst
else if test -e $dst
    set ts (date +%s)
    mv $dst $dst.backup-$ts
    echo "📦 Backed up existing $dst → $dst.backup-$ts"
end

if ln -s $src $dst
    echo "🔗 Linked theme-toggle → $dst"
else
    echo "❌ Failed to link theme-toggle"
    exit 1
end

echo "🎨 Theme toggle ready."
echo "💡 Toggle from anywhere: theme-toggle"
echo "💡 Inside tmux:           prefix + T"
echo "💡 Inside nvim:           <leader>tt"
