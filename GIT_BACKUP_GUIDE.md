# Git Backup & Version Control Guide

**Purpose:** How to use Git to restore older versions and manage backups

---

## Yes, Git Provides Full Backup History!

Every commit is a backup. You can go back to any previous version of your project.

---

## Viewing Your Backup History

### See All Commits (Backups)

```bash
# See last 10 commits
git log --oneline -10

# See all commits with details
git log

# See commits with file changes
git log --stat

# See commits in a graph
git log --oneline --graph --all
```

### See What Changed in a Commit

```bash
# See what changed in a specific commit
git show [commit-hash]

# See what changed between commits
git diff [commit-hash-1] [commit-hash-2]

# See what files changed
git show --name-only [commit-hash]
```

---

## Restoring Previous Versions

### Restore a Specific File to Previous Version

```bash
# See history of a specific file
git log --oneline [file-path]

# Restore file to a specific commit
git checkout [commit-hash] -- [file-path]

# Example: Restore a file from 3 commits ago
git checkout HEAD~3 -- game/scripts/player_controller.gd
```

### Restore Entire Project to Previous Version

```bash
# See commit history first
git log --oneline

# Go back to a specific commit (creates detached HEAD)
git checkout [commit-hash]

# Create a new branch from old version (safer)
git checkout -b restore-old-version [commit-hash]

# Or reset to old version (WARNING: loses newer commits)
git reset --hard [commit-hash]
```

### Restore Deleted Files

```bash
# See deleted files in a commit
git log --diff-filter=D --summary

# Restore deleted file from last commit that had it
git checkout HEAD~1 -- [deleted-file-path]

# Or restore from specific commit
git checkout [commit-hash] -- [deleted-file-path]
```

---

## Safe Restoration Methods

### Method 1: Create a Branch (Recommended)

```bash
# Create a branch from old version
git checkout -b restore-from-backup [commit-hash]

# Now you're on the old version
# Make changes, test, etc.

# If you want to keep it, merge back:
git checkout master
git merge restore-from-backup

# If you don't want it, just delete the branch:
git checkout master
git branch -D restore-from-backup
```

### Method 2: Restore Specific Files Only

```bash
# Restore just the files you need
git checkout [commit-hash] -- path/to/file1.gd path/to/file2.gd

# Commit the restored files
git add .
git commit -m "Restore files from previous version"
git push
```

### Method 3: Create a Tag for Important Versions

```bash
# Tag current version as backup
git tag backup-2025-01-27

# Push tag to GitHub
git push origin backup-2025-01-27

# Later, restore from tag
git checkout backup-2025-01-27
```

---

## Finding What You Need

### Search Commit Messages

```bash
# Search commits by message
git log --grep="inventory"

# Search commits by author
git log --author="keemo"

# Search commits by date
git log --since="2025-01-01" --until="2025-01-31"
```

### Find When a File Was Changed

```bash
# See all changes to a file
git log --follow -- [file-path]

# See what changed in a file
git log -p -- [file-path]
```

### Find When a Bug Was Introduced

```bash
# See when a specific line changed
git blame [file-path]

# Binary search for when bug appeared
git bisect start
git bisect bad  # Current version has bug
git bisect good [old-commit-hash]  # Old version worked
# Git will help you find the exact commit
```

---

## GitHub Backup Features

### View on GitHub

1. Go to: https://github.com/TviperHD/pixel-sandbox-survival-ai
2. Click "Commits" to see all backups
3. Click any commit to see what changed
4. Click "Browse files" on any commit to see that version

### Download Old Version from GitHub

1. Go to commit on GitHub
2. Click "Browse files"
3. Click "Code" → "Download ZIP"
4. Extract and use that version

### Create Release from Old Version

```bash
# Tag an old version
git tag v1.0 [commit-hash]
git push origin v1.0

# Now it appears in GitHub Releases
```

---

## Phase Milestones (Easy Restore Points)

Since you have phase milestones, you can easily restore to phase completions:

```bash
# See all phase milestones
git tag -l "phase-*"

# Restore to Phase 1 completion
git checkout phase-1

# Create branch from Phase 1
git checkout -b restore-phase-1 phase-1
```

---

## Common Scenarios

### "I deleted a file by mistake"

```bash
# Find when it was deleted
git log --diff-filter=D --summary

# Restore it
git checkout HEAD~1 -- [file-path]
git add .
git commit -m "Restore deleted file"
git push
```

### "My code is broken, I want yesterday's version"

```bash
# Find yesterday's commit
git log --since="yesterday" --until="now"

# Restore specific files
git checkout [yesterday-commit-hash] -- path/to/broken/file.gd

# Or restore everything
git checkout [yesterday-commit-hash]
```

### "I want to see what changed last week"

```bash
# See commits from last week
git log --since="1 week ago"

# See what files changed
git diff --stat HEAD~7 HEAD
```

### "I want to compare two versions"

```bash
# Compare two commits
git diff [commit-hash-1] [commit-hash-2]

# Compare current with old version
git diff [old-commit-hash] HEAD

# See only file names that changed
git diff --name-only [commit-hash-1] [commit-hash-2]
```

---

## Important Notes

### Local vs Remote Backups

- **Local commits** = Backed up on your computer
- **Pushed commits** = Backed up on GitHub (safe even if computer breaks)

**Always push to GitHub for true backup!**

### Safety Tips

1. **Don't use `git reset --hard`** unless you're sure (loses commits)
2. **Create branches** when experimenting with old versions
3. **Tag important versions** for easy access
4. **Push regularly** so GitHub has your backups

### What Gets Backed Up

✅ **Everything committed:**
- All code files
- All documentation
- All configuration files
- Project structure

❌ **NOT backed up (via .gitignore):**
- `.godot/` folder (build cache)
- `.import/` folder (imported assets)
- Temporary files
- User-specific settings

---

## Quick Reference

| Task | Command |
|------|---------|
| View history | `git log --oneline` |
| See what changed | `git show [commit-hash]` |
| Restore file | `git checkout [commit-hash] -- [file]` |
| Restore everything | `git checkout [commit-hash]` |
| Create branch from old | `git checkout -b restore [commit-hash]` |
| Find deleted file | `git log --diff-filter=D` |
| Search commits | `git log --grep="search term"` |
| View on GitHub | Go to repo → Commits |

---

## Example: Restore a File

```bash
# 1. See file history
git log --oneline -- game/scripts/player_controller.gd

# Output:
# abc1234 Fix movement bug
# def5678 Add jump function
# ghi9012 Initial player controller

# 2. Restore from before the bug
git checkout def5678 -- game/scripts/player_controller.gd

# 3. Commit the restore
git add .
git commit -m "Restore player controller to version before bug"
git push
```

---

**Remember:** Every commit is a backup. With regular commits, you have a complete history of your project and can restore to any point in time!

---

**Last Updated:** 2025-01-27

