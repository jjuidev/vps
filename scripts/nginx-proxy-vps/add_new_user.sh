#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$BASE_DIR/.env"

if [ -z "$NEW_USER" ]; then
  exit 1
fi

if id "$NEW_USER" &>/dev/null; then
  exit 1
fi

echo "Adding new user: $NEW_USER..."

sudo useradd -m -s /bin/bash "$NEW_USER"

# Set password (default to username if not provided)
PASSWORD="${NEW_USER_PASSWORD:-$NEW_USER}"
echo "$NEW_USER:$PASSWORD" | sudo chpasswd

# Set additional user information if provided
[ -n "$NEW_USER_FULL_NAME" ] && echo "" | sudo chfn -f "$NEW_USER_FULL_NAME" "$NEW_USER" 2>/dev/null || true
[ -n "$NEW_USER_ROOM" ] && echo "" | sudo chfn -r "$NEW_USER_ROOM" "$NEW_USER" 2>/dev/null || true
[ -n "$NEW_USER_WORK_PHONE" ] && echo "" | sudo chfn -w "$NEW_USER_WORK_PHONE" "$NEW_USER" 2>/dev/null || true
[ -n "$NEW_USER_HOME_PHONE" ] && echo "" | sudo chfn -h "$NEW_USER_HOME_PHONE" "$NEW_USER" 2>/dev/null || true
[ -n "$NEW_USER_OTHER" ] && echo "" | sudo chfn -o "$NEW_USER_OTHER" "$NEW_USER" 2>/dev/null || true

sudo usermod -aG sudo "$NEW_USER"
sudo usermod -aG docker "$NEW_USER"

echo "✅ User $NEW_USER added to sudo, docker groups successfully!"
