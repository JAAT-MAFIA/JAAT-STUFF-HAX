param($verFile)
if (-not (Test-Path $verFile)) {
    "1.0"
} else {
    $raw = (Get-Content $verFile).Trim()
    $clean = $raw.TrimStart('v')
    $parts = $clean.Split('.')
    if ($parts.Count -ge 2) {
        $major = [int]$parts[0]
        $minor = [int]$parts[1] + 1
        "$major.$minor"
    } else {
        "1.0"
    }
}
