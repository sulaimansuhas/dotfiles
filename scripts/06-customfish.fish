#!/usr/bin/env fish
# scripts/06-customfish.fish
# Seed ~/.config/customFish with a skeleton if this machine has none.
# These files are machine-local and never committed — config.fish sources
# main.fish when present; env.fish holds env vars and secrets.

echo "🐠 Setting up customFish..."

set dir ~/.config/customFish
mkdir -p $dir

if test -f $dir/main.fish
    echo "✅ $dir/main.fish exists, leaving it alone"
else
    printf '%s\n' \
        '# Machine-local fish config, sourced by config.fish when present.' \
        '# Aliases, functions, and paths for this machine go here.' \
        '' \
        'if test -f ~/.config/customFish/env.fish' \
        '    source ~/.config/customFish/env.fish' \
        'end' >$dir/main.fish
    echo "✅ Seeded $dir/main.fish"
end

if test -f $dir/env.fish
    echo "✅ $dir/env.fish exists, leaving it alone"
else
    printf '%s\n' \
        '# Environment variables for this machine (sourced by main.fish).' \
        '# Secrets live here and never enter the dotfiles repo.' >$dir/env.fish
    echo "✅ Seeded $dir/env.fish"
end
