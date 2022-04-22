#!/bin/bash
# File: 511-dns-bind9-service-default.sh
# Title: Service default startup setting for Bind9
# Description:
#
# Prerequisites:
#
# Env varnames
#   - BUILDROOT - '/' for direct installation, otherwise create 'build' subdir
#   - RNDC_CONF - rndc configuration file
#   - NAMED_CONF - named configuration file
#   - INSTANCE - Bind9 instance name, if any
#

echo "Create SysV and Systemd default file for ISC Bind9 named daemon"
echo

FILE_SETTING_PERFORM=true
source ./maintainer-dns-isc.sh

readonly FILE_SETTINGS_FILESPEC="${BUILDROOT}/file-bind9-service-defaults${INSTANCE_FILEPART}.sh"

# Even if we are root, we abide by BUILDROOT directive as to
# where the final configuration settings goes into.
ABSPATH="$(dirname "$BUILDROOT")"
if [ "$ABSPATH" != "." ] && [ "${ABSPATH:0:1}" != '/' ]; then
  echo "$BUILDROOT is an absolute path, we probably need root privilege"

  echo "We are backing up old bind/named settings"
  # Only the first copy is saved as the backup
  if [ ! -f "${NAMED_CONF_FILESPEC}.backup" ]; then
    BACKUP_FILENAME=".backup-$(date +'%Y%M%d%H%M')"
    echo "Moving /etc/bind/* to /etc/bind/${BACKUP_FILENAME}/ ..."
    mv "$NAMED_CONF_FILESPEC" "${NAMED_CONF_FILESPEC}.backup"
    retsts=$?
    if [ $retsts -ne 0 ]; then
      echo "ERROR: Failed to create a backup of /etc/${ETC_SUB_DIRNAME}/*"
      exit 3
    fi
  fi
else
  echo "Creating subdirectories to $BUILDROOT ..."
  mkdir -p "$BUILDROOT"
  # mkdir -p "${BUILDROOT}${CHROOT_DIR}$sysconfdir"
  # flex_mkdir "$sysconfdir"
  # flex_mkdir "$extended_sysconfdir"
  # flex_mkdir "$INIT_DEFAULT_DIRSPEC"

  echo "Creating file permission script in $FILE_SETTINGS_FILESPEC ..."
  echo "#!/bin/bash" > "$FILE_SETTINGS_FILESPEC"
  # shellcheck disable=SC2094
  { \
  echo "# File: $(basename "$FILE_SETTINGS_FILESPEC")"; \
  echo "# Path: ${PWD}/$(dirname "$FILE_SETTINGS_FILESPEC")"; \
  echo "# Title: File permission settings for ISC Bind9 named daemon"; \
  } >> "$FILE_SETTINGS_FILESPEC"
fi
echo


function create_sysv_default() {

  # Make it work for both 'rndc.conf' and 'rndc-public.conf', et. al.
  # /etc/default/bind9
  # /etc/default/bind9-default
  # /etc/default/bind9-public

  # build/etc/default
  flex_ckdir "$ETC_DIRSPEC"
  flex_ckdir "$INIT_DEFAULT_DIRSPEC"

  echo "Creating ${BUILDROOT}${CHROOT_DIR}$INSTANCE_INIT_DEFAULT_FILESPEC"
  cat << EOF | tee "${BUILDROOT}${CHROOT_DIR}$INSTANCE_INIT_DEFAULT_FILESPEC" >/dev/null
#
# File: ${INSTANCE_INIT_DEFAULT_FILENAME}
# Path: ${INIT_DEFAULT_DIRSPEC}
# Generated by: $(basename $0)
# Title: OS-specific settings for Bind9 systemd-unit/service
#
#     RNDC_OPTIONS - passthru CLI options for 'rndc' utility
#                    cannot use -p option (use RNDC_PORT)
#                    cannot use -c option (uses /etc/${ETC_SUB_DIRNAME}/named-%I.conf)
#
#     RESOLVCONF - Do a one-shot resolv.conf setup. 'yes' or 'no'
#           Only used in SysV/s6/OpenRC/ConMan; Ignored by systemd.
#
# run resolvconf?  (legacy sysV initrd)
RESOLVCONF=no

# default settings for startup options  of 'bind9'
#
# NAMED_PIDFILE="/run/bind/named.pid"
#
# NAMED_CONF="/etc/bind/named.conf"
#
# NAMED_OPTIONS="-c ${NAMED_CONF_FILESPEC}"
# NAMED_CHECKCONF_OPTIONS="-z ${NAMED_CONF_FILESPEC}"
# RNDC_OPTIONS="-c $RNDC_CONF_FILESPEC -p 953 -s localhost"
#
RNDC_BIN="/usr/sbin/rndc"
NAMED_BIN="/usr/sbin/named"
NAMED_CHECKCONF_BIN="/usr/sbin/named-checkconf"

# the "rndc.conf" should have all its server, key, port, and IP address defined
RNDC_OPTIONS="-c ${INSTANCE_RNDC_CONF_FILESPEC}"

# Do not use '-f' or '-g' option in NAMED_CONF
NAMED_CONF="-c ${NAMED_CONF_FILESPEC}"

# There may be other settings in a unit-instance-specific default
# file such as /etc/default/${sysvinit_unitname}-public.conf or
# /etc/default/bind9-dmz.conf.
EOF
}


create_sysv_default

echo
echo "Done."

