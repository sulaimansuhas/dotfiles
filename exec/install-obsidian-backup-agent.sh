#!/bin/sh

set -eu

LABEL="com.suhas.obsidian-git-backup"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
INTERVAL_SECONDS="${OBSIDIAN_BACKUP_INTERVAL_SECONDS:-900}"
SCRIPT_DIR=$(CDPATH= cd "$(dirname "$0")" && pwd)
BACKUP_SCRIPT="$SCRIPT_DIR/git-backup.sh"

xml_escape() {
    printf '%s' "$1" \
        | sed \
            -e 's/&/\&amp;/g' \
            -e 's/</\&lt;/g' \
            -e 's/>/\&gt;/g' \
            -e 's/"/\&quot;/g' \
            -e "s/'/\&apos;/g"
}

usage() {
    echo "Usage: $0 /path/to/obsidian-vault"
    echo "       $0 --uninstall"
}

if [ "${1:-}" = "--uninstall" ]; then
    launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
    rm -f "$PLIST"
    echo "Removed $PLIST"
    exit 0
fi

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

VAULT="$1"

if [ ! -d "$VAULT" ]; then
    echo "Error: $VAULT is not a directory" >&2
    exit 1
fi

if [ ! -d "$VAULT/.git" ] && [ ! -f "$VAULT/.git" ]; then
    echo "Error: $VAULT is not a git repository" >&2
    exit 1
fi

if [ ! -x "$BACKUP_SCRIPT" ]; then
    chmod +x "$BACKUP_SCRIPT"
fi

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

ESC_BACKUP_SCRIPT=$(xml_escape "$BACKUP_SCRIPT")
ESC_VAULT=$(xml_escape "$VAULT")
ESC_STDOUT=$(xml_escape "$HOME/Library/Logs/$LABEL.out.log")
ESC_STDERR=$(xml_escape "$HOME/Library/Logs/$LABEL.err.log")

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>$ESC_BACKUP_SCRIPT</string>
        <string>$ESC_VAULT</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>$INTERVAL_SECONDS</integer>

    <key>StandardOutPath</key>
    <string>$ESC_STDOUT</string>

    <key>StandardErrorPath</key>
    <string>$ESC_STDERR</string>
</dict>
</plist>
EOF

plutil -lint "$PLIST"

launchctl bootout "gui/$(id -u)" "$PLIST" >/dev/null 2>&1 || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/$LABEL"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "Installed $LABEL"
echo "Vault: $VAULT"
echo "Interval: $INTERVAL_SECONDS seconds"
echo "Logs:"
echo "  $HOME/Library/Logs/$LABEL.out.log"
echo "  $HOME/Library/Logs/$LABEL.err.log"
