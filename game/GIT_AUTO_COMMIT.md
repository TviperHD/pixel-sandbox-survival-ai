# Automatic Git Commits

**Location:** `game/` folder  
**Purpose:** Automatic Git commits for Cursor AI changes

---

## How It Works

When Cursor AI makes changes to your project, it will automatically commit them to Git and push to GitHub.

### Automatic Commit Process

1. **AI makes changes** (creates/edits files)
2. **AI automatically runs:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```
3. **Changes are backed up** to GitHub immediately

---

## Commit Message Guidelines

### Good Commit Messages:
- `"Add player movement controller"`
- `"Implement inventory item stacking logic"`
- `"Survival: Add hunger/thirst decay system"`
- `"Fix bug in crafting recipe validation"`
- `"Phase 1: Complete foundation systems"`

### Format:
- Use present tense
- Be specific about what changed
- Include system name if relevant
- Keep it concise (one line)

---

## Phase Milestones

When completing a phase, create a milestone tag:

```bash
# From project root
git tag -a phase-1 -m "Phase 1: Foundation Systems Complete"
git push origin phase-1
```

**Available phases:**
- phase-0: Foundation Setup
- phase-1: Foundation Systems
- phase-2: Core Gameplay Systems
- phase-3: World & Environment Systems
- phase-4: AI & Progression Systems
- phase-5: Content Systems
- phase-6: UI/UX Systems
- phase-7: Advanced Systems
- phase-8: Integration & Testing
- phase-9: Polish & Release

---

## Manual Commits

If you need to commit manually:

**From project root:**
```bash
git add .
git commit -m "Your commit message"
git push
```

**Or use the helper scripts:**
```powershell
# From game/ folder - Regular commit
.\auto-commit.ps1 "Your commit message"

# From game/ folder - Create phase milestone
.\create-phase-milestone.ps1 1 "Foundation Systems Complete"
```

---

## What Gets Committed

**Automatically committed:**
- All code changes (`.gd` files)
- All scene files (`.tscn` files)
- All resource files (`.tres` files)
- Documentation updates
- Configuration changes

**NOT committed (via .gitignore):**
- `.godot/` folder
- `.import/` folder
- Build artifacts
- Temporary files
- User-specific settings

---

## Workflow

### During Development:

1. **AI implements a feature**
2. **AI automatically commits:**
   ```
   git add .
   git commit -m "Implement [feature name]"
   git push
   ```
3. **Changes backed up** to GitHub

### Completing a Phase:

1. **AI completes all phase tasks**
2. **AI commits final changes:**
   ```
   git add .
   git commit -m "Phase X: [Phase name] Complete"
   git push
   ```
3. **AI creates milestone tag:**
   ```
   git tag -a phase-X -m "Phase X: [Phase name] Complete"
   git push origin phase-X
   ```

---

## Viewing Commits

**View commit history:**
```bash
git log --oneline
```

**View specific commit:**
```bash
git show [commit-hash]
```

**View changes:**
```bash
git diff
```

---

## Troubleshooting

### If commit fails:
- Check you're in the project root
- Verify Git is configured: `git config user.name` and `git config user.email`
- Check GitHub connection: `git remote -v`

### If push fails:
- Check internet connection
- Verify GitHub credentials
- Check if repository exists on GitHub

---

## Notes

- **Commits happen automatically** - AI handles this for you
- **All changes are backed up** - Nothing gets lost
- **Phase milestones** - Easy to track progress
- **Commit history** - Full record of all changes

---

**Last Updated:** 2025-01-27

