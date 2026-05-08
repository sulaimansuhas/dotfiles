#!/bin/sh

timestamp() {
    date '+%Y-%m-%d %H:%M:%S %z'
}

log() {
    printf '%s repo=%s %s\n' "$(timestamp)" "${LOG_REPO:-unknown}" "$*"
}

is_online() {
    ping -q -c 1 -W 1 github.com >/dev/null 2>&1
}

has_unmerged_files() {
    [ -n "$(git diff --name-only --diff-filter=U)" ]
}

current_branch() {
    git symbolic-ref --quiet --short HEAD 2>/dev/null
}

upstream_remote() {
    BRANCH=$(current_branch) || return 1
    git config "branch.$BRANCH.remote"
}

has_upstream() {
    git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1
}

sync_remote_changes() {
    if ! is_online; then
        log "Offline: skipping fetch/pull"
        return 0
    fi

    if ! has_upstream; then
        log "No upstream configured: skipping fetch/pull"
        return 0
    fi

    REMOTE=$(upstream_remote) || {
        log "Unable to determine upstream remote"
        return 1
    }

    log "Fetching from $REMOTE"
    if ! git fetch "$REMOTE"; then
        log "Fetch failed"
        return 1
    fi

    set -- $(git rev-list --left-right --count HEAD...'@{u}')
    AHEAD="$1"
    BEHIND="$2"

    if [ "$BEHIND" -gt 0 ]; then
        log "Remote is $BEHIND commit(s) ahead; rebasing local changes"

        if ! git pull --rebase --autostash; then
            log "Rebase failed: resolve conflicts in this repo, then run the backup again"
            return 1
        fi
    elif [ "$AHEAD" -gt 0 ]; then
        log "Local branch is $AHEAD commit(s) ahead of upstream"
    fi
}

push_pending_commits() {
    REPO="$1"

    if ! is_online; then
        log "No changes"
        return 0
    fi

    if ! has_upstream; then
        log "No changes"
        return 0
    fi

    set -- $(git rev-list --left-right --count HEAD...'@{u}')
    AHEAD="$1"

    if [ "$AHEAD" -gt 0 ]; then
        log "Pushing $AHEAD pending commit(s)"
        if ! git push; then
            log "Push failed"
            return 1
        fi
    else
        log "No changes"
    fi
}

log_staged_files() {
    COUNT=$(git diff --cached --name-only | wc -l | tr -d ' ')

    log "Staged $COUNT changed file(s)"
    git diff --cached --name-status | while IFS= read -r FILE_STATUS; do
        log "Changed file: $FILE_STATUS"
    done
}

backup_repo() {
    REPO="$1"
    LOG_REPO="$REPO"

    if [ ! -d "$REPO" ]; then
        log "Skipping: not a directory"
        return
    fi

    if [ ! -d "$REPO/.git" ] && [ ! -f "$REPO/.git" ]; then
        log "Skipping: not a git repo"
        return
    fi

    (
        LOG_REPO="$REPO"
        if ! cd "$REPO"; then
            log "Unable to enter repo directory"
            exit 1
        fi

        BRANCH=$(current_branch || printf 'detached')
        if has_upstream; then
            UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}')
        else
            UPSTREAM="none"
        fi
        log "Starting backup branch=$BRANCH upstream=$UPSTREAM"

        if has_unmerged_files; then
            log "Skipping: unresolved merge conflicts"
            exit 1
        fi

        sync_remote_changes || exit 1

        if has_unmerged_files; then
            log "Skipping: unresolved merge conflicts"
            exit 1
        fi

        if ! git add -A; then
            log "git add failed"
            exit 1
        fi

        if ! git diff --cached --quiet; then
            log_staged_files
            if git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M:%S')"; then
                if is_online; then
                    log "Pushing backup commit"
                    if ! git push; then
                        log "Push failed"
                        exit 1
                    fi
                else
                    log "Skipping push: offline"
                fi
            else
                log "Commit failed"
                exit 1
            fi
        else
            push_pending_commits "$REPO" || exit 1
        fi

        log "Finished backup"
    )
}

if [ "$#" -eq 0 ]; then
    LOG_REPO="unknown"
    log "Usage: $0 /path/to/repo1 [/path/to/repo2 ...]"
    exit 1
fi

for repo in "$@"; do
    backup_repo "$repo"
done
