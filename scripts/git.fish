#!/usr/bin/env fish
# scripts/01-git-config.fish

echo "📝 Setting up Git configuration..."

if not command -v git >/dev/null
    echo "❌ Git not found"
    exit 1
end

read -P "Git username: " git_user
read -P "Git email: " git_email

git config --global user.name "$git_user"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global push.default simple
git config --global pull.rebase false

echo "✅ Git configured"
