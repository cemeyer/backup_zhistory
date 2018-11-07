#!/bin/sh

# Used in cron:
# * * * * * $HOME/src/backup_zhistory/bzh.sh

ZHBD="$HOME/.zhistory-backups"

mkdir -p "$ZHBD"

# 1. Locate latest backup
LASTBKUP="$(ls -tr $ZHBD/ | tail -n1)"

# 2. Compare against current history file
zstdcat "$ZHBD/$LASTBKUP" | cmp -s "$HOME/.zhistory" - 
if [ $? -ne 0 ]; then
    # 3. New backup

    OFILE="$ZHBD/zhistory-$(date +"%Y-%m-%d_%H:%M:%S").zst"
    zstd --quiet --check --threads=0 -12 --keep -o "$OFILE" \
	< "$HOME/.zhistory"

    fsync "$OFILE"
    fsync "$ZHBD"
    fsync "$HOME"
fi
