# AI Development Rules - Quick Reference

## 📋 Files Created

### 1. `.cursorrules` (Main Rules File)
Comprehensive guidelines for AI coding assistants working on this project.

**Location**: Root directory  
**Size**: ~17KB  
**Sections**: 20+ detailed sections covering all aspects of development

### 2. `.windsurfrules` & `.aidigestorrules`
Reference files that point to the main `.cursorrules` file for cross-platform compatibility.

---

## 🎯 The 5 Core Rules

### 1️⃣ Follow Development Process
- Always check `docs/development_process.md` before starting
- Work phase by phase (0 → 11)
- Don't skip ahead to later phases

### 2️⃣ Update Progress
- Mark checkboxes `[x]` after completing tasks
- Update `development_process.md` immediately
- Keep documentation in sync

### 3️⃣ Stick to Scope
- ONLY implement features in PRD and tasks breakdown
- No additional features without approval
- No scope creep

### 4️⃣ Ask When Uncertain
- Unclear requirements? → Ask
- Missing details? → Ask
- Technical choices? → Ask
- UI/UX decisions? → Propose options

### 5️⃣ Prioritize UX/UI
- Modern, beautiful design
- Smooth 60 FPS animations
- Clear feedback for all actions
- Accessibility first

---

## 📊 What's Covered in .cursorrules

### Development Guidelines
- ✅ Project overview and context
- ✅ Phase-by-phase development approach
- ✅ Clean Architecture structure
- ✅ Testing requirements (>90% coverage)
- ✅ Code quality standards
- ✅ Git workflow

### Technical Standards
- ✅ Flutter best practices
- ✅ State management patterns
- ✅ Error handling strategies
- ✅ Security requirements
- ✅ Performance optimization

### Game-Specific Rules
- ✅ Server-authoritative logic
- ✅ Modifier implementation order
- ✅ Real-time multiplayer handling
- ✅ Edge case coverage

### UI/UX Guidelines
- ✅ Design principles
- ✅ Screen-specific requirements
- ✅ Animation standards
- ✅ Accessibility requirements

### Project Management
- ✅ MVP vs Post-MVP prioritization
- ✅ Definition of Done checklist
- ✅ Documentation requirements
- ✅ Anti-patterns to avoid

---

## 🚦 Quick Decision Trees

### "Should I implement this?"
```
Is it in the PRD/tasks?
├─ YES → Is it current phase?
│         ├─ YES → ✅ Do it!
│         └─ NO → ⏳ Wait
└─ NO → 🛑 Ask first
```

### "Should I ask or do?"
```
Is it 100% clear?
├─ YES → ✅ Do it
└─ NO → 🛑 Ask
```

---

## 💡 Common Scenarios

### ✅ DO
- Follow phases in order
- Write tests with code
- Update docs after tasks
- Ask for clarification
- Fix all linter errors
- Use const constructors
- Handle edge cases

### ❌ DON'T
- Skip phases
- Add unlisted features
- Commit broken code
- Hardcode values
- Skip tests
- Ignore linter
- Assume requirements

---

## 🎯 MVP Focus (Phases 0-4)

### ✅ Build These First
- Core 3x3 gameplay
- Matchmaking (basic)
- 2 simple modifiers
- Real-time multiplayer
- Basic auth
- Essential UI

### ⏳ Build These Later
- Social sharing
- Leaderboards
- Store/monetization
- Advanced modifiers
- Achievements

---

## 📖 Key Documents

1. **development_process.md** → Current phase, task list
2. **tech_prd_1_0.md** → What to build
3. **tasks_breakdown.md** → How to build it
4. **.cursorrules** → How to code it

---

## 🔄 Typical Workflow

1. Check current phase in `development_process.md`
2. Pick next uncompleted task
3. Implement with tests
4. Fix linter errors
5. Update `development_process.md` checkbox
6. Move to next task

---

## 📞 When to Ask

### Always Ask About:
- ❓ Ambiguous requirements
- ❓ Missing technical details
- ❓ UI/UX approach
- ❓ Technology choices
- ❓ Game rule edge cases
- ❓ Conflicting information

### Example Good Questions:
- "Should I use Riverpod or Bloc?"
- "The explosion radius isn't specified. Adjacent cells only?"
- "Do you have mockups for the matchmaking screen?"
- "Should we handle simultaneous disconnects?"

---

## 🎨 UI/UX Standards

### Design Principles
1. **Clarity** - Instantly understandable
2. **Delight** - Personality through animation
3. **Speed** - Fast interactions
4. **Consistency** - Reuse patterns

### Performance Targets
- 60 FPS animations
- <2s load time
- <10s matchmaking
- >99.5% crash-free

---

## ✅ Definition of Done

A task is complete when:
- [x] Code written and styled
- [x] Tests written and passing
- [x] Linter shows 0 errors
- [x] Docs updated
- [x] Checkbox marked in development_process.md
- [x] Tested on iOS & Android

---

## 🎉 TL;DR

**3 Things to Remember**:
1. Follow `development_process.md` religiously
2. Only build what's in PRD/tasks
3. Ask when unsure (always better than assuming)

**Mission**: Build a beautiful, viral, multiplayer Tic-Tac-Toe game with modifiers. Quality > Speed. UX > Features.

---

For complete details, see `.cursorrules` in the root directory.

