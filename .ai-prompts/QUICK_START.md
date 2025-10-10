# Prompt Logging - Quick Start Guide

## 🚀 Quick Reference

### After Each AI Session

1. **Create new log file**:
   ```bash
   # File name format: YYYY-MM-DD_HHMM_brief-description.md
   touch .ai-prompts/2025-10-10_1430_your-description.md
   ```

2. **Copy template**:
   ```bash
   cp .ai-prompts/TEMPLATE.md .ai-prompts/2025-10-10_1430_your-description.md
   ```

3. **Fill in the details**:
   - Date & time
   - Token usage (check AI response)
   - Prompt summary
   - What was created/modified
   - Tags for easy searching

4. **Update index**:
   - Add entry to `.ai-prompts/README.md`

---

## 📋 Essential Fields

| Field | Example | Where to Find |
|-------|---------|---------------|
| **Date** | 2025-10-10 | Current date |
| **Time** | 14:30 | Use 24-hour format |
| **Tokens** | 50,000 | AI response footer |
| **Phase** | Phase 0 | Check `docs/development_process.md` |
| **Tags** | `[phase-0]` `[setup]` | Based on work done |

---

## 💡 File Naming Tips

### Good Names ✅
- `2025-10-10_1430_create-game-logic.md`
- `2025-10-10_1545_fix-simulator-bug.md`
- `2025-10-11_0900_implement-matchmaking.md`

### Bad Names ❌
- `prompt.md` (not specific)
- `session1.md` (not timestamped)
- `2025-10-10.md` (missing time, too vague)
- `fix.md` (not descriptive enough)

---

## 🏷️ Common Tags

**By Phase**:
- `[phase-0]` - Foundation & Setup
- `[phase-1]` - Core Architecture
- `[phase-2]` - Core UI & Game Flow
- `[phase-3]` - Essential Features
- `[phase-4]` - MVP Testing

**By Type**:
- `[feature]` - New feature
- `[bug-fix]` - Fixing issues
- `[refactor]` - Code improvement
- `[documentation]` - Docs work
- `[testing]` - Test creation

**By Technology**:
- `[flutter]` `[dart]` `[firebase]`
- `[ios]` `[android]`
- `[ui]` `[backend]` `[database]`

---

## 📊 Token Usage Tracking

### Where to Find Token Count

**Cursor**:
- Look at bottom of AI response
- Format: "Token usage: X/1000000"

**Windsurf**:
- Check response metadata
- Usually shown in status bar

**Claude/GPT API**:
- Check API response headers
- Or use token counter tools

### Estimating Costs

Approximate costs (check current pricing):
- Claude Sonnet: ~$3 per 1M tokens
- GPT-4: ~$30 per 1M tokens
- GPT-3.5: ~$2 per 1M tokens

**Example**:
- 50,000 tokens ≈ $0.15 (Claude Sonnet)

---

## 🎯 What to Include

### Must Have ✅
- Full original prompt
- Token count
- Files created/modified
- Brief summary

### Should Have 👍
- Key decisions made
- Issues encountered
- Follow-up actions
- Related sessions

### Optional 💡
- Screenshots
- Code snippets
- Learnings
- Prompting tips

---

## 🔍 Searching Logs

### By Date
```bash
ls .ai-prompts/2025-10-* 
```

### By Topic
```bash
grep -r "[game-logic]" .ai-prompts/
```

### By File Modified
```bash
grep -r "main.dart" .ai-prompts/
```

---

## 📈 Best Practices

1. **Log immediately** - Don't wait, details fade fast
2. **Be specific** - Future you will thank you
3. **Include context** - Why this prompt was needed
4. **Link related** - Reference previous sessions
5. **Update index** - Keep README.md current
6. **Review monthly** - Learn from patterns

---

## ⚡ Time-Saving Tips

### 1. Use Aliases
Add to `~/.zshrc`:
```bash
alias newprompt='date "+.ai-prompts/%Y-%m-%d_%H%M_"'
# Usage: newprompt feature-name.md
```

### 2. Create Script
```bash
#!/bin/bash
# save as: new-prompt-log.sh
TIMESTAMP=$(date "+%Y-%m-%d_%H%M")
FILE=".ai-prompts/${TIMESTAMP}_$1.md"
cp .ai-prompts/TEMPLATE.md "$FILE"
echo "Created: $FILE"
open "$FILE"  # or: code "$FILE"
```

### 3. IDE Snippet
Create snippet for your IDE that generates the timestamp format.

---

## 🎓 Example Session

```bash
# 1. Start AI session in Cursor

# 2. After completion, create log
cp .ai-prompts/TEMPLATE.md .ai-prompts/2025-10-10_1430_game-board.md

# 3. Fill in details
# - Copy your original prompt
# - Note: Created GameBoard widget, 3 test files
# - Tokens: 25,000
# - Tags: [phase-2] [ui] [widgets]

# 4. Update README index
# Add row to session table

# 5. Commit with log
git add .ai-prompts/2025-10-10_1430_game-board.md
git commit -m "feat: implement game board widget

See .ai-prompts/2025-10-10_1430_game-board.md for details"
```

---

## 📞 Need Help?

- **Template not clear?** See `TEMPLATE.md` for full example
- **Not sure what to log?** When in doubt, log it!
- **Forgot to log?** Better late than never, add it now
- **Token count unknown?** Estimate and mark as "~estimated"

---

## ✅ Checklist

After each AI session:
- [ ] Create timestamped log file
- [ ] Fill in prompt and summary
- [ ] Record token usage
- [ ] List files created/modified
- [ ] Add relevant tags
- [ ] Update README index
- [ ] Commit log file

---

**Remember**: These logs are for YOUR benefit. The more detail now, the more value later! 💪

