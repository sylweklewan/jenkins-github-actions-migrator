#!/bin/bash

KUBECONFIG_PATH="$1"
PUBLIC_IP="$2"
SSH_KEY_PATH="$3"
DEFAULT_SSH_PORT="22"
DEFAULT_SSH_USER="user"
DEFAULT_KUBE_PORT="8443"


if [ -z "$KUBECONFIG_PATH" ] || [ -z "$PUBLIC_IP" ] || [ -z "$SSH_KEY_PATH" ]; then
  echo "❌ Usage: $0 <kubeconfig_path> <client_cert_path> <client_key_path> <public_ip> <ssh_key>"
  exit 1
fi

SSH_PORT="${4:-$DEFAULT_SSH_PORT}"
SSH_USER="${5:-$DEFAULT_SSH_USER}"
KUBE_PORT="${6:-$DEFAULT_KUBE_PORT}"

echo "🔧 Patching kubeconfig at $KUBECONFIG_PATH"

# Download kubeconfig from EC2
scp -P "${SSH_PORT}" -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -i "${SSH_KEY_PATH}" "${SSH_USER}@${PUBLIC_IP}:/home/${SSH_USER}/.kube/config" "${KUBECONFIG_PATH}"

# Patch kubeconfig
tmpfile=$(mktemp)
awk -v server_ip="$PUBLIC_IP" -v port="$KUBE_PORT" '
  BEGIN { updated = 0 }
  /certificate-authority-data:/ {
    print "    insecure-skip-tls-verify: true"
    updated = 1
    next
  }
  /server:/ {
    print "    server: https://" server_ip ":" port 
    next
  }
  { print }
  END {
    if (updated == 0) {
      print "    insecure-skip-tls-verify: true"
    }
  }
' "$KUBECONFIG_PATH" > "$tmpfile" && mv "$tmpfile" "$KUBECONFIG_PATH"