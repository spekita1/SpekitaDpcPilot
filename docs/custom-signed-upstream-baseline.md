# Custom-signed upstream baseline

`pilot-v0.2.0` is a controlled Device Owner provisioning experiment.

The release workflow downloads the official TestDPC 9.0.12 APK, verifies its
fixed SHA-256 digest and official signing certificate, then signs that verified
APK with the Spekita release key. The application package, Device Admin
component, code, and resources remain the upstream TestDPC baseline; only the
APK container and signing identity change.

This build is diagnostic and must not be used in production.

## Interpreting the pilot

- If `pilot-v0.1.1` and `pilot-v0.2.0` both provision successfully, the Spekita
  signing identity is accepted and the earlier failure is inside the custom DPC
  build or implementation.
- If `pilot-v0.1.1` succeeds but `pilot-v0.2.0` fails, the changed signing
  identity is the isolated variable and should be investigated before further
  DPC customization.

Run this pilot on a separate factory-reset test device. Preserve the phone that
successfully completed the `pilot-v0.1.1` control test.
