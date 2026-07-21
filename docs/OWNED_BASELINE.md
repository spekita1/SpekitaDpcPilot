# Owned TestDPC baseline

This pilot builds the exact, unchanged TestDPC v9.0.12 source and signs it with a
Spekita-owned key. It is a diagnostic Device Owner baseline, not a production
release. The app will still appear as **Test DPC** during enrollment.

Use Device Owner management only on devices you own or administer with the
device user's informed consent.

## Protect the signing key

Back up the keystore and its passwords securely. If the key is lost, Android
will not accept future updates to the DPC installed with that key.

From Windows PowerShell, create the key and configure the repository secrets:

```powershell
$ks="$env:USERPROFILE\Documents\spekita-dpc-release.jks"
keytool -genkeypair -v -keystore $ks -storetype PKCS12 -alias spekita-dpc -keyalg RSA -keysize 4096 -validity 10000
$base64=[Convert]::ToBase64String([IO.File]::ReadAllBytes($ks))
$base64 | gh secret set DPC_KEYSTORE_BASE64 --repo spekita1/SpekitaDpcPilot
gh secret set DPC_KEYSTORE_PASSWORD --repo spekita1/SpekitaDpcPilot
gh secret set DPC_KEY_ALIAS --repo spekita1/SpekitaDpcPilot --body "spekita-dpc"
gh secret set DPC_KEY_PASSWORD --repo spekita1/SpekitaDpcPilot
```

Run the manual workflow:

```powershell
gh workflow run build-owned-baseline.yml --repo spekita1/SpekitaDpcPilot -f confirmation=BUILD_OWNED_DPC_BASELINE
```

## Pilot test

1. Factory-reset the test phone.
2. Tap the welcome screen six times and connect to Wi-Fi.
3. Scan `provisioning-qr.png` from the `pilot-v0.2.0-owned` release.
4. Choose **Use for work only** and finish setup.

Success means the phone completes setup and shows **Test DPC** as Device Owner.
Only after that result should branding and Spekita behavior be introduced, one
small and independently tested change at a time.
