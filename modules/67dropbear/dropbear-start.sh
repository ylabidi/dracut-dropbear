#!/bin/sh

. /etc/dropbear/dropbear.conf

# Linux >= 6.2 allows the TIOCSTI ioctl to be disabled by default;
# console_auth requires it, so re-enable using the provided sysctl
if [ -w /proc/sys/dev/tty/legacy_tiocsti ]; then
  cp /proc/sys/dev/tty/legacy_tiocsti /tmp/legacy_tiocsti.default >/dev/null 2>&1
  echo 1 > /proc/sys/dev/tty/legacy_tiocsti
fi

[ -f /tmp/dropbear.pid ] && kill -0 $(cat /tmp/dropbear.pid) 2>/dev/null || {
  info "sshd port: ${port}"
  for key_type in $key_types; do
    eval fingerprint=\$dropbear_${key_type}_fingerprint
    eval bubble=\$dropbear_${key_type}_bubble
    info "Boot SSH ${key_type} key parameters: "
    info "  fingerprint: ${fingerprint}"
    info "  bubblebabble: ${bubble}"
  done

  /sbin/dropbear -s -j -k -p "${port}" -P /tmp/dropbear.pid
  [ $? -gt 0 ] && info 'Dropbear sshd failed to start'
}
