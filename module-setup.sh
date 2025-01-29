#!/bin/bash


_do_fail() {
  local message
  message="$1"
  derror "${message}"
  return 1
}

_ensure_key() {
  local key_type key_path
  key_type="$1"
  key_path="$2"
  [ ! -f "${key_path}" ] && {
    dropbearkey -t "${key_type}" -f "${key_path}"
  }
}

check() {
  require_binaries dropbear || _do_fail "Dropbear should be installed first"
  return 0
}

depends() {
  echo "network"
  return 0
}

install() {

  # Read dropbear configuration
  # shellcheck disable=SC1091
  source /etc/dracut.conf.d/04-dropbear.conf

  # Some initialization
  [ -z "${port}" ] && _do_fail "Dropbear listening port missing"
  [ -z "${acl_path}" ] && _do_fail "Path to accessing public key missing"
  [ -z "${key_types}" ] && _do_fail "Supported key types missing"
  #
  local tmp_dir target_conf target_conf_path
  tmp_dir=$(mktemp -d --tmpdir dracut-dropbear.XXXX)
  target_conf="${tmp_dir}/dropbear.conf"
  target_conf_path="/etc/dropbear/dropbear.conf"

  # Start writing the conf for initramfs include
  echo -e "#!/bin/bash\n\n" > "${target_conf}"
  echo "key_types='${key_types}'" >> "${target_conf}"
  echo "port='${port}'" >> "${target_conf}"

  # Go over different encryption key types
  local key_type key_path key_bubble key_fingerprint
  for key_type in $key_types; do
    key_path="/etc/dropbear/dropbear_${key_type}_key_path"
    # Verify key and generate it if missing
    _ensure_key "${key_type}" "${key_path}"
    # Install and show some information
    key_fingerprint=$(ssh-keygen -l -f "${key_path}.pub")
    key_bubble=$(ssh-keygen -B -f "${key_path}.pub")
    dinfo "Boot SSH ${key_type} key parameters: "
    dinfo "  fingerprint: ${key_fingerprint}"
    dinfo "  bubblebabble: ${key_bubble}"

    echo "dropbear_${key_type}_fingerprint='${key_fingerprint}'" >> "${target_conf}"
    echo "dropbear_${key_type}_bubble='${key_bubble}'" >> "${target_conf}"
    inst "${key_path}"
  done

  inst "${target_conf}" "${target_conf_path}"

  # shellcheck disable=SC2154
  inst_rules "${moddir}/50-udev-pty.rules"
  inst_hook pre-udev 99 "${moddir}/dropbear-start.sh"
  inst_hook pre-pivot 05 "${moddir}/dropbear-stop.sh"

  # shellcheck disable=SC2154
  inst "${acl}" /root/.ssh/authorized_keys

  # Cleanup
  rm -rf "${tmp_dir}"
  
  # Install the required binaries
  dracut_install pkill setterm
  inst_libdir_file "libnss_files*"

  # Dropbear should always be in /sbin so the start script works
  local dropbear
  if dropbear="$(command -v dropbear 2>/dev/null)"; then
    inst "${dropbear}" /sbin/dropbear
  else
    _do_fail "Unable to locate dropbear executable"
  fi

}
