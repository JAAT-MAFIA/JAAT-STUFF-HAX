param([string]$VersionFile)

# Read current version or start at 1.0
if (Test-Path $VersionFile) {
    $ver = (Get-Content $VersionFile -Raw).Trim()
} else {
    $ver = "1.0"
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
