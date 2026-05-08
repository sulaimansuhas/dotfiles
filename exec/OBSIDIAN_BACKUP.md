# Obsidian Git backup

The scripts in this directory can back up an Obsidian vault by committing
changes to Git and pushing them to the configured remote.

## One-off backup

Run:

```sh
./git-backup.sh /path/to/obsidian-vault
```

For each repository path, `git-backup.sh`:

- skips paths that are not directories
- skips paths that are not Git repositories
- refuses to run if Git already has unresolved merge conflicts
- fetches from the configured upstream when online
- rebases local work on top of upstream when the remote is ahead
- stages all changes with `git add -A`
- logs the staged file list with Git status letters before committing
- commits changes with an `Auto backup: YYYY-MM-DD HH:MM:SS` message
- pushes the commit if `github.com` is reachable
- pushes previously-created local backup commits when a later run is online

Because the script stages everything, keep a useful `.gitignore` in the vault.
For Obsidian, common ignores are:

```gitignore
.obsidian/workspace.json
.obsidian/workspace-mobile.json
.obsidian/cache
.trash/
.DS_Store
```

## GitHub SSH setup

Use an SSH host alias for GitHub so the Obsidian vault always uses the intended
key. For example, in `~/.ssh/config`:

```sshconfig
Host github-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/turing_private
  IdentitiesOnly yes
  AddKeysToAgent yes
  UseKeychain yes
  UpdateHostKeys yes
```

Parameter meanings:

- `Host github-personal`: local SSH alias used by Git remotes and `ssh`
- `HostName github.com`: real server SSH connects to
- `User git`: required SSH user for GitHub
- `IdentityFile ~/.ssh/turing_private`: private key to use for this alias
- `IdentitiesOnly yes`: only offer the configured key, not every key in the agent
- `AddKeysToAgent yes`: add the key to the running SSH agent after use
- `UseKeychain yes`: macOS option to store and retrieve the key passphrase from Keychain
- `UpdateHostKeys yes`: allow SSH to learn updated GitHub server host keys

Add the key to the macOS Keychain-backed SSH agent:

```sh
ssh-add --apple-use-keychain ~/.ssh/turing_private
```

Test GitHub authentication:

```sh
ssh -T git@github-personal
```

GitHub should respond with a message saying authentication succeeded and that it
does not provide shell access.

Make the Obsidian vault remote use the alias:

```sh
cd /path/to/obsidian-vault
git remote set-url origin git@github-personal:YOUR_USER/YOUR_REPO.git
git remote -v
```

The remote should show `git@github-personal:YOUR_USER/YOUR_REPO.git`.

## Conflict behavior

The backup script does not automatically resolve note conflicts. That is
intentional: automatic conflict resolution can silently lose Obsidian content.

When online, the script fetches from the configured upstream before committing.
If the remote branch has newer commits, it runs:

```sh
git pull --rebase --autostash
```

That handles the common case where another device pushed changes and the local
vault has unrelated edits. If Git can rebase cleanly, the script continues,
creates the backup commit, and pushes it.

If Git finds a real conflict, the script stops and logs:

```text
Rebase failed: resolve conflicts in this repo, then run the backup again
```

Resolve it manually:

```sh
cd /path/to/obsidian-vault
git status
```

Open the conflicted files, resolve the conflict markers, then continue the
rebase:

```sh
git add -A
git rebase --continue
git push
```

After that, the automation can continue normally.

## macOS automation

Install the LaunchAgent with:

```sh
./install-obsidian-backup-agent.sh /path/to/obsidian-vault
```

This creates:

```text
~/Library/LaunchAgents/com.suhas.obsidian-git-backup.plist
```

The agent runs:

- when it is loaded
- when you log in
- about every 15 minutes while the Mac is awake and you are logged in

macOS `launchd` will also run missed interval jobs after sleep when it gets the
chance. This is usually enough for "run after wake" behavior, but it is not a
dedicated wake hook. If an exact run on every wake is needed, use a wake-aware
tool such as SleepWatcher or Hammerspoon to call `git-backup.sh`.

Logs are written to:

```text
~/Library/Logs/com.suhas.obsidian-git-backup.out.log
~/Library/Logs/com.suhas.obsidian-git-backup.err.log
```

Script log lines include a timestamp and the repository path:

```text
2026-05-08 20:30:00 +0100 repo=/path/to/obsidian-vault Starting backup branch=main upstream=origin/main
2026-05-08 20:30:01 +0100 repo=/path/to/obsidian-vault Staged 2 changed file(s)
2026-05-08 20:30:01 +0100 repo=/path/to/obsidian-vault Changed file: M	Some Note.md
2026-05-08 20:30:01 +0100 repo=/path/to/obsidian-vault Changed file: A	New Note.md
```

The changed-file lines use Git's `name-status` format. Common status letters
are `M` for modified, `A` for added, `D` for deleted, and `R` for renamed.

To change the interval at install time, set `OBSIDIAN_BACKUP_INTERVAL_SECONDS`.
For example, 5 minutes:

```sh
OBSIDIAN_BACKUP_INTERVAL_SECONDS=300 ./install-obsidian-backup-agent.sh /path/to/obsidian-vault
```

To uninstall:

```sh
./install-obsidian-backup-agent.sh --uninstall
```

## Testing

Test the backup script directly:

```sh
./git-backup.sh /path/to/obsidian-vault
```

Force the LaunchAgent to run:

```sh
launchctl kickstart -k gui/$(id -u)/com.suhas.obsidian-git-backup
```

Check LaunchAgent state:

```sh
launchctl print gui/$(id -u)/com.suhas.obsidian-git-backup
```

Check logs:

```sh
tail -n 100 ~/Library/Logs/com.suhas.obsidian-git-backup.out.log
tail -n 100 ~/Library/Logs/com.suhas.obsidian-git-backup.err.log
```
