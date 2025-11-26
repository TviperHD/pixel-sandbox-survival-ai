# Automatic Git Commit Script
# This script automatically commits changes with a descriptive message
# Usage: .\auto-commit.ps1 "Description of changes"

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = ""
)

# Navigate to project root (from game/ folder)
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

# Check if we're in a git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a git repository!" -ForegroundColor Red
    exit 1
}

# Check if there are any changes
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No changes to commit." -ForegroundColor Yellow
    exit 0
}

# Show what changed
Write-Host "=== Changes Detected ===" -ForegroundColor Cyan
git status --short
Write-Host ""

# Generate commit message if not provided
if ([string]::IsNullOrWhiteSpace($Message)) {
    # Try to generate a message from changed files
    $changedFiles = git diff --name-only --cached
    if ([string]::IsNullOrWhiteSpace($changedFiles)) {
        $changedFiles = git diff --name-only
    }
    
    if (-not [string]::IsNullOrWhiteSpace($changedFiles)) {
        $fileList = $changedFiles -split "`n" | Select-Object -First 3
        $Message = "Update: " + ($fileList -join ", ")
    } else {
        $Message = "Auto-commit: " + (Get-Date -Format "yyyy-MM-dd HH:mm")
    }
}

# Add all changes
Write-Host "Adding all changes..." -ForegroundColor Yellow
git add .

# Commit
Write-Host "Committing: $Message" -ForegroundColor Yellow
git commit -m $Message

# Push
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
git push

Write-Host ""
Write-Host "✓ Successfully committed and pushed!" -ForegroundColor Green
Write-Host "Commit message: $Message" -ForegroundColor Cyan

