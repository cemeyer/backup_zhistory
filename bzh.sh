#!/bin/sh

# Used in cron:
# * * * * * $HOME/src/backup_zhistory/bzh.sh

ZHBD="$HOME/.zhistory-backups"
DIGESTFILE="/tmp/$USER/backup_zhistory.sha512"

mkdir -p "$ZHBD"

# 1. Compare last hash against current history file
( sha512 < "$HOME/.zhistory" ) | \
if ! cmp -s "$DIGESTFILE" - ; then

    # 3. New backup
    OFILE="$ZHBD/zhistory-$(date +"%Y-%m-%d_%H:%M:%S")"

    cp -a "$HOME/.zhistory" "$OFILE"
    sha512 < "$OFILE" > "${DIGESTFILE}"
    zstd --quiet --check --threads=0 -12 --rm "$OFILE"

    fsync "${OFILE}.zst"
    fsync "$ZHBD"
    #fsync "$HOME"
fi
