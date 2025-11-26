# Git Commit Helper Script
# Usage: .\commit-changes.ps1 "Your commit message"

param(
    [Parameter(Mandatory=$true)]
    [string]$Message
)

Write-Host "=== Git Commit Helper ===" -ForegroundColor Cyan
Write-Host ""

# Check if we're in a git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a git repository!" -ForegroundColor Red
    exit 1
}

# Show current status
Write-Host "Checking git status..." -ForegroundColor Yellow
git status --short

Write-Host ""
$response = Read-Host "Do you want to commit these changes? (y/n)"

if ($response -ne "y" -and $response -ne "Y") {
    Write-Host "Commit cancelled." -ForegroundColor Yellow
    exit 0
}

# Add all changes
Write-Host ""
Write-Host "Adding all changes..." -ForegroundColor Yellow
git add .

# Commit with message
Write-Host "Committing with message: $Message" -ForegroundColor Yellow
git commit -m $Message

# Ask if user wants to push
Write-Host ""
$pushResponse = Read-Host "Push to GitHub? (y/n)"

if ($pushResponse -eq "y" -or $pushResponse -eq "Y") {
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push
    Write-Host ""
    Write-Host "✓ Successfully pushed to GitHub!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "Changes committed locally. Run 'git push' when ready." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

