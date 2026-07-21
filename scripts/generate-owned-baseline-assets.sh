#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 4 || $# -gt 7 ]]; then
  echo "Usage: $0 <apk> <download-url> <output-directory> <signature-checksum> [source-commit] [official-apk-sha256] [official-signature-checksum]" >&2
  exit 64
fi

apk="$1"
download_url="$2"
output_directory="$3"
signature_checksum="$4"
source_commit="${5:-unknown}"
official_apk_sha256="${6:-unknown}"
official_signature_checksum="${7:-unknown}"

if [[ ! -f "$apk" ]]; then
  echo "APK does not exist: $apk" >&2
  exit 66
fi

mkdir -p "$output_directory"

package_name="com.afwsamples.testdpc"
component_name="com.afwsamples.testdpc/com.afwsamples.testdpc.DeviceAdminReceiver"
apk_sha256_hex="$(sha256sum "$apk" | awk '{print $1}')"
apk_sha256_base64url="$(printf '%s' "$apk_sha256_hex" \
  | xxd -r -p | openssl base64 -A | tr '+/' '-_' | tr -d '=')"

jq -n \
  --arg component "$component_name" \
  --arg url "$download_url" \
  --arg checksum "$signature_checksum" \
  '{
    "android.app.extra.PROVISIONING_DEVICE_ADMIN_COMPONENT_NAME": $component,
    "android.app.extra.PROVISIONING_DEVICE_ADMIN_PACKAGE_DOWNLOAD_LOCATION": $url,
    "android.app.extra.PROVISIONING_DEVICE_ADMIN_SIGNATURE_CHECKSUM": $checksum,
    "android.app.extra.PROVISIONING_LEAVE_ALL_SYSTEM_APPS_ENABLED": true,
    "android.app.extra.PROVISIONING_SKIP_ENCRYPTION": false
  }' > "$output_directory/provisioning.json"

qrencode -l M -m 4 -s 12 \
  -o "$output_directory/provisioning-qr.png" \
  < "$output_directory/provisioning.json"

jq -n \
  --arg baseline "official-testdpc-v9.0.12-resigned-only" \
  --arg package "$package_name" \
  --arg component "$component_name" \
  --arg url "$download_url" \
  --arg apk_sha256_hex "$apk_sha256_hex" \
  --arg apk_sha256_base64url "$apk_sha256_base64url" \
  --arg signature_checksum "$signature_checksum" \
  --arg source_commit "$source_commit" \
  --arg official_apk_sha256 "$official_apk_sha256" \
  --arg official_signature_checksum "$official_signature_checksum" \
  '{
    baseline: $baseline,
    package_name: $package,
    component_name: $component,
    download_url: $url,
    apk_sha256_hex: $apk_sha256_hex,
    apk_sha256_base64url: $apk_sha256_base64url,
    signature_checksum: $signature_checksum,
    published_signature_checksum: $signature_checksum,
    official_signature_checksum: $official_signature_checksum,
    official_apk_sha256_hex: $official_apk_sha256,
    source_commit: $source_commit
  }' > "$output_directory/provisioning-metadata.json"
