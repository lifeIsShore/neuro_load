# encode_keystore.ps1
# This script helps you Base64-encode your Android keystore for GitHub Secrets.

$keystorePath = Read-Host "Enter the path to your .jks keystore file (e.g., neuroload-release.jks)"

if (!(Test-Path $keystorePath)) {
    Write-Host "❌ File not found: $keystorePath" -ForegroundColor Red
    return
}

try {
    $bytes = [IO.File]::ReadAllBytes((Resolve-Path $keystorePath))
    $base64 = [Convert]::ToBase64String($bytes)
    $base64 | Set-Clipboard
    Write-Host "`n✅ Success! The Base64-encoded string has been copied to your clipboard." -ForegroundColor Green
    Write-Host "Next steps:"
    Write-Host "1. Go to your GitHub repository -> Settings"
    Write-Host "2. Secrets and variables -> Actions -> New repository secret"
    Write-Host "3. Name: KEYSTORE_BASE64"
    Write-Host "4. Value: (Paste your clipboard content)"
} catch {
    Write-Host "❌ Failed to encode file: $_" -ForegroundColor Red
}
