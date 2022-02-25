#!/bin/bash
# File: 200-systemd-bootup-no-clear-screen.sh
# Title: Do not clear the screen after last kernel output during bootup
#
echo "Disable clearing of screen after kernel bootup (and before login prompt)"
echo
if [ "$UID" -ne 0 ]; then
  echo "You are not root; this will prompt you for a SUDO password."
  echo "Ctrl-C to abort."
  read -rp "Enter in 'y' to continue: "
  if [ "${REPLY:0:1}" != 'y' ]; then
    echo
    echo "Aborted."
    exit 1
  fi
  SUDO_BIN="/usr/bin/sudo"
fi
service_unit_filename="boot-no-clear-screen.conf"
service_unit_dirspec="/etc/systemd/system/getty@tty1.service.d"
service_unit_filespec="${service_unit_dirspec}/$service_unit_filename"

$SUDO_BIN mkdir "$service_unit_dirspec"

echo "Writing $service_unit_filespec ..."
cat << SYSTEMD_UNIT_TWEAK_EOF | $SUDO_BIN tee "$service_unit_filespec" > /dev/null
#!/bin/bash
# File: 200-systemd-bootup-no-clear-screen.sh
# Title: Do not clear the VT screen after last kernel output during bootup
# Generated by: $(basename $0)
# Created on: $(date)
# Description:
#
#   Disable the clearing action of Virtual Terminal TTY1 screen 
#   that occurs after its kernel bootup (and before its login prompt)
#
#   Note: You can always review the boot output instead by executing:
#
#       journalctl -b
#
[Service]
TTYVTDisallocate=no

SYSTEMD_UNIT_TWEAK_EOF
$SUDO_BIN chmod 0640      "$service_unit_filespec"
$SUDO_BIN chown root:root "$service_unit_filespec"
echo "File permission setted."
echo
echo "Next time you boot, the login prompt on this"
echo "host's virtualterminal tty1 (Ctrl-F1) will"
echo "occur right after the last line of kernel"
echo "boot output (dmesg)"

echo
echo "Done."
