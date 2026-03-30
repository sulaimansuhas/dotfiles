#!/bin/sh

backup_repo() {
    REPO="$1"

    if [ ! -d "$REPO" ]; then
        echo "Skipping: $REPO (not a directory)"
        return
    fi

    if [ ! -d "$REPO/.git" ]; then
        echo "Skipping: $REPO (not a git repo)"
        return
    fi

    cd "$REPO" || return

    git add -A

    if ! git diff --cached --quiet; then
        git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"

        if ping -q -c 1 -W 1 github.com >/dev/null 2>&1; then
            git push
        else
            echo "Skipping push for $REPO (offline)"
        fi
    else
        echo "No changes: $REPO"
    fi
}

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 /path/to/repo1 [/path/to/repo2 ...]"
    exit 1
fi

for repo in "$@"; do
    backup_repo "$repo"
done
