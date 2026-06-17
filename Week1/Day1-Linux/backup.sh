#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/backups"

function print_usage() {
    echo "Usage: $0 [-h|--help] <directory_path>"
    echo "Creates a compressed tar.gz backup of the specified directory in $BACKUP_DIR."
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    print_usage
    exit 0
fi

if [[ $# -eq 0 ]]; then
    print_usage
    exit 1
fi

TARGET_DIR="$1"

if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory named '$TARGET_DIR' not exist"
    exit 2
fi

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
DIR_NAME=$(basename "$TARGET_DIR")
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/${DIR_NAME}-${TIMESTAMP}.tar.gz"
echo "Creating backup of $TARGET_DIR in $BACKUP_DIR ..."
tar -czf "$BACKUP_FILE" "$TARGET_DIR"
echo "Backup of $TARGET_DIR created successfully in $BACKUP_DIR"

FILE_COUNT=$(find "$TARGET_DIR" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$TARGET_DIR" | cut -f1)
echo "Number of files backed up: $FILE_COUNT"
echo "Total size: $TOTAL_SIZE"
