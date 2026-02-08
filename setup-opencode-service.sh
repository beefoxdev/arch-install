#!/usr/bin/env bash
set -euo pipefail
# OpenCode systemd user service bootstrap
# - Stores password in ~/.local/state/opencode/credentials/server_password
# - Uses systemd LoadCredential
# - Creates/updates ~/.config/systemd/user/opencode.service
# - Enables and starts the service
SERVICE_NAME="opencode.service"
CRED_DIR="${HOME}/.local/state/opencode/credentials"
CRED_FILE="${CRED_DIR}/server_password"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SYSTEMD_USER_DIR}/${SERVICE_NAME}"
HOST="${OPENCODE_HOST:-0.0.0.0}"
PORT="${OPENCODE_PORT:-4096}"
RESET_PASSWORD=false
if [[ "${1:-}" == "--reset-password" ]]; then
  RESET_PASSWORD=true
fi
if ! command -v systemctl >/dev/null 2>&1; then
  echo "Error: systemctl not found."
  exit 1
fi
if ! systemctl --user --version >/dev/null 2>&1; then
  echo "Error: systemd user services are not available in this session."
  exit 1
fi
if [[ -x "${HOME}/.opencode/bin/opencode" ]]; then
  OPENCODE_BIN="${HOME}/.opencode/bin/opencode"
elif command -v opencode >/dev/null 2>&1; then
  OPENCODE_BIN="$(command -v opencode)"
else
  echo "Error: could not find 'opencode' binary."
  echo "Expected ${HOME}/.opencode/bin/opencode or something on PATH."
  exit 1
fi
echo "Using opencode binary: ${OPENCODE_BIN}"
# Create credential directory with strict permissions
install -d -m 700 "${CRED_DIR}"
# Create or rotate password file
if [[ ! -f "${CRED_FILE}" || "${RESET_PASSWORD}" == true ]]; then
  read -rsp "OpenCode server password: " OPENCODE_PW
  echo
  umask 077
  printf '%s\n' "${OPENCODE_PW}" > "${CRED_FILE}"
  unset OPENCODE_PW
  chmod 600 "${CRED_FILE}"
  echo "Wrote credential file: ${CRED_FILE}"
else
  chmod 600 "${CRED_FILE}"
  echo "Credential file already exists: ${CRED_FILE}"
fi
# Create systemd user unit directory
install -d -m 700 "${SYSTEMD_USER_DIR}"
# Write/update service file
cat > "${SERVICE_FILE}" <<EOF
[Unit]
Description=OpenCode Server
After=network.target
[Service]
ExecStart=/bin/sh -c 'OPENCODE_SERVER_PASSWORD=\$(cat "\$CREDENTIALS_DIRECTORY/opencode_password") exec ${OPENCODE_BIN} serve --hostname ${HOST} --port ${PORT}'
LoadCredential=opencode_password:%h/.local/state/opencode/credentials/server_password
Restart=on-failure
[Install]
WantedBy=default.target
EOF
chmod 644 "${SERVICE_FILE}"
echo "Wrote service file: ${SERVICE_FILE}"
# Reload and start
systemctl --user daemon-reload
systemctl --user enable --now "${SERVICE_NAME}"
echo
echo "Service status:"
systemctl --user status "${SERVICE_NAME}" --no-pager || true
echo
echo "Recent logs:"
journalctl --user -u "${SERVICE_NAME}" -n 30 --no-pager || true
echo
echo "Done."
