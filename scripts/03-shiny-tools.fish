#!/usr/bin/env fish
# scripts/04-cargo-tools.fish

if not command -v cargo >/dev/null
    echo "❌ Cargo not found"
    exit 1
end

set cargo_tools \
    "ripgrep" \
    "bat" \
    "exa" \
    "fd-find" \
    "tokei"
   # "hyperfine"

for tool in $cargo_tools
    echo "📦 Installing $tool..."
    if cargo install $tool
        echo "✅ $tool installed"
    else
        echo "❌ Failed to install $tool"
    end
end

echo "✅ Cargo tools installation complete"

