# Create Phase Milestone Tag
# Usage: .\create-phase-milestone.ps1 <phase-number> "Description"

param(
    [Parameter(Mandatory=$true)]
    [int]$PhaseNumber,
    
    [Parameter(Mandatory=$true)]
    [string]$Description
)

Write-Host "=== Create Phase Milestone ===" -ForegroundColor Cyan
Write-Host ""

# Validate phase number
if ($PhaseNumber -lt 0 -or $PhaseNumber -gt 9) {
    Write-Host "Error: Phase number must be between 0 and 9!" -ForegroundColor Red
    exit 1
}

# Check if we're in a git repository
if (-not (Test-Path .git)) {
    Write-Host "Error: Not in a git repository!" -ForegroundColor Red
    exit 1
}

# Check if tag already exists
$tagName = "phase-$PhaseNumber"
$existingTag = git tag -l $tagName

if ($existingTag) {
    Write-Host "Warning: Tag '$tagName' already exists!" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite existing tag? (y/n)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
    # Delete local tag
    git tag -d $tagName
    # Delete remote tag if it exists
    git push origin :refs/tags/$tagName 2>$null
}

# Create annotated tag
$tagMessage = "Phase $PhaseNumber : $Description"
Write-Host "Creating tag: $tagName" -ForegroundColor Yellow
Write-Host "Message: $tagMessage" -ForegroundColor Yellow
Write-Host ""

git tag -a $tagName -m $tagMessage

# Ask if user wants to push tag
$pushResponse = Read-Host "Push tag to GitHub? (y/n)"

if ($pushResponse -eq "y" -or $pushResponse -eq "Y") {
    Write-Host "Pushing tag to GitHub..." -ForegroundColor Yellow
    git push origin $tagName
    Write-Host ""
    Write-Host "✓ Milestone '$tagName' created and pushed!" -ForegroundColor Green
    Write-Host "View on GitHub: https://github.com/TviperHD/pixel-sandbox-survival-ai/releases/tag/$tagName" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Tag created locally. Run 'git push origin $tagName' when ready." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green

