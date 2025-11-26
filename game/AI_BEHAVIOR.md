# AI Behavior: Git Commit Enforcement

## How This Works

The `.cursor/rules/git-auto-commit.mdc` file contains a **MANDATORY** rule that instructs Cursor AI to automatically commit changes.

### Rule Application

1. **Cursor reads `.mdc` files** in `.cursor/rules/` automatically
2. **The `alwaysApply: true` metadata** ensures this rule is always considered
3. **The `priority: critical` metadata** gives it high importance
4. **Explicit instructions** tell the AI exactly when and how to commit

### Current Setup

- ✅ Rule file exists: `game/.cursor/rules/git-auto-commit.mdc`
- ✅ Has `alwaysApply: true` metadata
- ✅ Has `priority: critical` metadata
- ✅ Contains explicit commit instructions
- ✅ Includes examples and enforcement language

### How AI Knows When to Commit

The rule explicitly states:
- **After making ANY changes** → Commit immediately
- **After implementing a feature** → Commit immediately
- **After fixing a bug** → Commit immediately
- **After updating documentation** → Commit immediately
- **Before continuing to next task** → Commit first

### Limitations

**Current limitation:** The AI must "remember" to follow the rule. While the rule is explicit and mandatory, there's no technical enforcement that prevents the AI from skipping it.

**Best practices implemented:**
- ✅ Rule is marked as `alwaysApply: true`
- ✅ Rule is marked as `priority: critical`
- ✅ Explicit, action-oriented language
- ✅ Multiple examples
- ✅ Clear violation warnings
- ✅ Step-by-step instructions

### Alternative Approaches (Not Currently Implemented)

1. **Git Hooks** - Would run automatically but only AFTER commits (not helpful for ensuring commits happen)
2. **File Watchers** - Could trigger commits on file changes, but complex to set up and may conflict with Cursor
3. **Post-Edit Scripts** - Would require Cursor API access (not available)
4. **CI/CD Automation** - Only works for pushed commits (doesn't help with local commits)

### Recommendations

**Current approach is best practice for Cursor AI:**
- ✅ Clear, explicit rules
- ✅ High priority metadata
- ✅ Always-apply metadata
- ✅ Action-oriented language
- ✅ Multiple enforcement points

**To verify it's working:**
- Check commit history after AI makes changes
- If commits are missing, remind AI of the rule
- The rule should be automatically applied by Cursor

---

**Last Updated:** 2025-01-27

