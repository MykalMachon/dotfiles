# Read package list
$json = Get-Content ".\packages.json" | ConvertFrom-Json

# Install git first as it's a requirement for buckets 
scoop install git

# Set execution policy and install scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
if (-not (Test-Path "$env:USERPROFILE\scoop")) {
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# Add buckets
foreach ($bucket in $json.buckets) {
    scoop bucket add $bucket
}

# Install all packages
foreach ($pkg in $json.cli + $json.gui + $json.fonts) {
    scoop install $pkg
}

# Setup oh-my-posh 
$ompConfigDir = "$env:USERPROFILE\.config\oh-my-posh"
New-Item -ItemType Directory -Path $ompConfigDir -Force | Out-Null

# Download an oh-my-posh theme
Invoke-WebRequest "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/powerlevel10k_modern.omp.json" `
    -OutFile "$ompConfigDir\powerlevel10k_modern.omp.json"

# Update PowerShell profile
$profileLine = 'oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\powerlevel10k_modern.omp.json" | Invoke-Expression'
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
} else {
    echo ""
}
if (-not (Select-String -Path $PROFILE -Pattern "oh-my-posh init")) {
    Add-Content -Path $PROFILE -Value "$profileLine"
}

. $PROFILE