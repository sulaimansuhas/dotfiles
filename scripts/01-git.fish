#!/usr/bin/env fish
# scripts/01-git-config.fish

echo "📝 Setting up Git configuration..."

if not command -v git >/dev/null
    echo "❌ Git not found"
    exit 1
end

# Check for existing git config
set current_name (git config --global user.name 2>/dev/null)
set current_email (git config --global user.email 2>/dev/null)

# Only ask for username if not already set
if test -z "$current_name"
    read -P "Git username: " git_user
    git config --global user.name "$git_user"
    echo "✅ Username set to: $git_user"
else
    echo "ℹ️  Username already configured: $current_name"
end

# Only ask for email if not already set  
if test -z "$current_email"
    read -P "Git email: " git_email
    git config --global user.email "$git_email"
    echo "✅ Email set to: $git_email"
else
    echo "ℹ️  Email already configured: $current_email"
end

git config --global init.defaultBranch main
git config --global push.default simple
git config --global pull.rebase false

echo "✅ Git configured"
