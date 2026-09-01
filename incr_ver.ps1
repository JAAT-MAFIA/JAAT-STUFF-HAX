param([string]$VersionFile)

# Read current version or start at 1.0
if (Test-Path $VersionFile) {
    $ver = (Get-Content $VersionFile -Raw).Trim()
} else {
    $ver = "1.0"
}

# If version is set to 1.0, preserve 1.0
if ($ver -eq "1.0") {
    Set-Content -Path $VersionFile -Value "1.0" -NoNewline
    Write-Output "1.0"
    exit 0
}

# Parse and increment minor version
$parts = $ver -split '\.'
$major = [int]$parts[0]
$minor = if ($parts.Length -gt 1) { [int]$parts[1] } else { 0 }
$minor++

$newVer = "$major.$minor"
Set-Content -Path $VersionFile -Value $newVer -NoNewline

# Output new version (captured by bat file)
Write-Output $newVer
