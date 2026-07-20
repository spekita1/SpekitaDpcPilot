#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <apk> <download-url> <output-directory> <signature-checksum>" >&2
  exit 2
fi

apk="$1"
download_url="$2"
output_directory="$3"
signature_checksum="$4"
mkdir -p "$output_directory"

apk_checksum="$({ openssl dgst -sha256 -binary "$apk" | openssl base64 -A; } | tr '+/' '-_' | tr -d '=')"

cat > "$output_directory/provisioning.json" <<EOF
{
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME": "com.afwsamples.testdpc/com.afwsamples.testdpc.DeviceAdminReceiver",
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION": "$download_url",
  "android.app.extra.PROVISIONING_DEVICE_ADMIN_SIGNATURE_CHECKSUM": "$signature_checksum",
  "android.app.extra.PROVISIONING_LEAVE_ALL_SYSTEM_APPS_ENABLED": true,
  "android.app.extra.PROVISIONING_SKIP_ENCRYPTION": false
}
EOF

cat > "$output_directory/provisioning-metadata.json" <<EOF
{
  "baseline": "official-testdpc-release-apk-verbatim",
  "package_name": "com.afwsamples.testdpc",
  "admin_receiver": "com.afwsamples.testdpc.DeviceAdminReceiver",
  "apk_name": "SpekitaDpcPilot.apk",
  "apk_url": "$download_url",
  "apk_sha256_base64url": "$apk_checksum",
  "official_signature_checksum": "$signature_checksum"
}
EOF

if command -v qrencode >/dev/null 2>&1; then
  qrencode -l M -m 4 -s 12 -o "$output_directory/provisioning-qr.png" < "$output_directory/provisioning.json"
fi

echo "Provisioning assets generated in $output_directory"
