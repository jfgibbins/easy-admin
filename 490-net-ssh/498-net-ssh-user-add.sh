#!/bin/bash
# File: 498-net-ssh-user-add.sh
# Title: Add authorized users to 'ssh' group for using 'ssh' tools


source ./maintainer-ssh-openssh.sh

echo "Adding '$SSH_GROUP_NAME' GID to a user's supplementary group"
echo

if [ $UID -ne 0 ]; then
  echo "WARNING: sudo password may appear."
fi

read -rp "Add the name of user to '$SSH_GROUP_NAME' group [$USER]?: "
if [ -z "$REPLY" ]; then
  SSH_USER="$USER"
else
  SSH_USER="$REPLY"
fi
echo ""

# check if user already has that supplemental group ID
USER_HAS_GID="$(grep -E -c "^${SSH_USER}:" /etc/group )"
if [ "$USER_HAS_GID" -ge 1 ]; then
  echo "User $SSH_USER already has $SSH_GROUP_NAME GID"
  echo ""
  echo "Done."
  exit 0
fi

# Add user to SSH group: who can log into this host?
echo "Executing: sudo addgroup $SSH_USER $SSH_GROUP_NAME"
sudo usermod -a -G "$SSH_GROUP_NAME" "$SSH_USER"
RETSTS=$?
if [ $RETSTS -ne 0 ]; then
  echo "Unable to add '$SSH_USER' user to '$SSH_GROUP_NAME' group: Error $RETSTS"
  exit $RETSTS
fi
echo ""

echo "Done."

