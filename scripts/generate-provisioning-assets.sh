#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <apk> <download-url> <output-directory>" >&2
  exit 2
fi

apk="$1"
download_url="$2"
output_directory="$3"
mkdir -p "$output_directory"

checksum="$({ openssl dgst -sha256 -binary "$apk" | openssl base64 -A; } | tr '+/' '-_' | tr -d '=')"

cat > "$output_directory/provisioning.json" <<EOF
{
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME": "com.afwsamples.testdpc/com.afwsamples.testdpc.DeviceAdminReceiver",
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION": "$download_url",
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_CHECKSUM": "$checksum",
  "android.app.extra.PROVISIONING_LEAVE_ALL_SYSTEM_APPS_ENABLED": true,
  "android.app.extra.PROVISIONING_SKIP_ENCRYPTION": false
}
EOF

cat > "$output_directory/provisioning-metadata.json" <<EOF
{
  "baseline": "official-testdpc-unmodified",
  "package_name": "com.afwsamples.testdpc",
  "admin_receiver": "com.afwsamples.testdpc.DeviceAdminReceiver",
  "apk_name": "SpekitaDpcPilot.apk",
  "apk_url": "$download_url",
  "apk_sha256_base64url": "$checksum"
}
EOF

if command -v qrencode >/dev/null 2>&1; then
  qrencode -l M -m 4 -s 12 -o "$output_directory/provisioning-qr.png" < "$output_directory/provisioning.json"
fi

echo "Provisioning assets generated in $output_directory"
