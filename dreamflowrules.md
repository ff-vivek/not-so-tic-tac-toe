# AI Coding Assistant Rules: Gridlock X & O Evolved

## 🎯 Project Overview
You are working on **Gridlock X & O Evolved**, a mobile-first, multiplayer Tic-Tac-Toe game with dynamic modifiers, built using Flutter. This project emphasizes viral mechanics, social sharing, and strategic gameplay.

---

## 📋 Core Development Rules

### 1. **Always Reference Development Process**
- **MANDATORY**: Check `docs/development_process.md` before starting any task to understand:
  - Current development phase (Phase 0-11)
  - Which tasks are MVP vs. Post-MVP
  - Task dependencies and sequencing
  - Specific implementation requirements
- Follow the phases in order: Don't implement Phase 5 features if Phase 1 isn't complete
- If uncertain about current phase, ask the developer

### 2. **Update Development Process After Each Task**
- After completing ANY task from `docs/development_process.md`:
  - Mark the completed checkbox from `[ ]` to `[x]`
  - Update the document immediately
  - Do NOT wait until end of session
- Example:
  ```markdown
  Before: - [ ] Implement core Tic-Tac-Toe logic
  After:  - [x] Implement core Tic-Tac-Toe logic
  ```
- If you complete multiple sub-tasks, update all relevant checkboxes

### 3. **Strict Feature Scope Adherence**
- **ONLY** implement features explicitly defined in:
  - `docs/tech_prd_1_0.md` (Product Requirements)
  - `docs/tasks_breakdown.md` (Epic breakdown)
- **DO NOT**:
  - Add features not in the PRD/tasks (no scope creep!)
  - Implement "nice to have" features without approval
  - Change game mechanics or rules
  - Add new modifiers beyond the 5 defined ones
- **If you think something is missing**: Ask the developer for clarification before implementing

### 4. **Clarification Protocol**
When you encounter ANY of the following, **STOP and ASK**:
- Ambiguous requirements or unclear specifications
- Conflicting information between docs
- Missing technical details (API structure, data models, etc.)
- Uncertainty about UI/UX approach
- Questions about game rules or edge cases
- Technology choices not specified (e.g., which state management library)

**Example questions to ask**:
- "The PRD mentions 'Volatile Squares' but doesn't specify explosion radius. Should it be adjacent cells only?"
- "Should we use Riverpod or Bloc for state management?"
- "The matchmaking screen design isn't in the docs. Do you have mockups or should I create a standard design?"

### 5. **Best UX & UI Practices**
- **Modern & Beautiful**: Design should feel premium, not generic
  - Use smooth animations (60 FPS target)
  - Implement micro-interactions (haptic feedback, sound effects)
  - Follow Material Design 3 / Cupertino guidelines
  - Consistent spacing and visual hierarchy
  
- **User-Centric Design**:
  - Minimize taps to core actions (1-tap to start playing)
  - Clear visual feedback for all interactions
  - Loading states should be engaging, not boring
  - Error messages should be helpful, not technical
  
- **Accessibility First**:
  - Sufficient color contrast (WCAG AA minimum)
  - Support for screen readers
  - Scalable text sizes
  - Haptic feedback for important actions
  
- **Performance**:
  - Smooth 60fps animations
  - Fast load times (<2 seconds to home screen)
  - Optimized images and assets
  - Efficient state management (no unnecessary rebuilds)

### 6. **Prompt Logging & Auditing** 🔍
- **MANDATORY**: All AI prompts must be logged for auditing and review purposes
- **What to Log**: Every interaction with AI coding assistants
  
**Logging Requirements**:
- Create a dedicated folder: `.ai-prompts/` in project root
- Save each prompt session as a separate markdown file
- File naming format: `YYYY-MM-DD_HHMM_[brief-description].md`
  - Example: `2025-10-10_1430_setup-development-scripts.md`
  - Example: `2025-10-10_1545_implement-game-logic.md`
  
**File Structure**:
```markdown
# Prompt Log: [Brief Description]

**Date**: YYYY-MM-DD
**Time**: HH:MM (24-hour format)
**Session Duration**: [duration] minutes
**Phase**: [Current Phase from development_process.md]

---

## 📊 Token Usage

- **Input Tokens**: [number]
- **Output Tokens**: [number]
- **Total Tokens**: [number]
- **Estimated Cost**: $[amount] (if applicable)

---

## 📝 Prompt Summary

[2-3 sentence summary of what was requested]

---

## 🎯 Goals

- [ ] Goal 1
- [ ] Goal 2
- [ ] Goal 3

---

## 💬 Full Prompt

```
[Complete original prompt text]
```

---

## 📤 AI Response Summary

[Brief summary of what the AI did/created]

**Files Created/Modified**:
- `path/to/file1.dart` - [description]
- `path/to/file2.dart` - [description]

**Tasks Completed**:
- [x] Task 1
- [x] Task 2

---

## 🔄 Development Process Updates

**Checkboxes marked complete**:
- Phase X, Section Y: [task name]

---

## 📌 Notes & Follow-ups

- Note 1
- Follow-up needed: [description]

---

## 🏷️ Tags

`[phase-0]` `[setup]` `[scripts]` `[documentation]`
```

**Best Practices**:
- Log immediately after AI session completes
- Be descriptive in file names (max 50 chars after timestamp)
- Update summary section before closing session
- Include actual token counts from AI response
- Tag with relevant phase and topics
- Link related prompt logs if multi-session work

**Folder Structure**:
```
.ai-prompts/
├── 2025-10-10_1200_initial-setup.md
├── 2025-10-10_1430_development-scripts.md
├── 2025-10-11_0900_game-architecture.md
└── README.md (index of all prompts)
```

**Why This Matters**:
- 📊 Track AI usage and costs
- 🔍 Audit development decisions
- 📚 Learn from past sessions
- 🎯 Understand feature evolution
- 💰 Budget management
- 🧠 Knowledge transfer to team

---

## 🏗️ Technical Implementation Standards

### Code Architecture
- **Clean Architecture**: Strictly follow the 3-layer separation:
  ```
  presentation/ → domain/ → data/
  (UI)         (Logic)    (Sources)
  ```
- No business logic in widgets
- No UI code in domain layer
- Repository pattern for all data access

### Code Quality Requirements
- **Testing**: Write tests BEFORE or WITH implementation (TDD encouraged)
  - Unit tests for all business logic (>90% coverage)
  - Widget tests for all UI components
  - Integration tests for critical flows
- **Documentation**: 
  - Add doc comments for public APIs
  - Complex algorithms need inline comments
  - Update README if adding new features
- **Linting**: Fix ALL linter errors before committing
  - Run `flutter analyze` and ensure 0 issues
  - Follow Dart style guide

### Flutter Best Practices
- Use `const` constructors wherever possible
- Prefer composition over inheritance
- Extract complex widgets into separate files
- Use meaningful variable names (no `a`, `b`, `temp`)
- Avoid deep nesting (max 3-4 levels)
- Handle null safety properly (no force unwraps without reason)

### Git Workflow
- **Commits**: Clear, descriptive messages
  - Good: "feat: implement blocked squares modifier logic"
  - Bad: "update", "fix stuff", "wip"
- **Branches**: Feature branches for all work
  - Format: `feature/epic-X-description`
  - Example: `feature/epic-1-matchmaking-service`
- **DO NOT**: Commit until explicitly asked
- **DO NOT**: Push to main/master without approval

---

## 🎮 Game-Specific Rules

### Game Logic
- **Server-Authoritative**: All game state validation MUST happen server-side
  - Client can optimistically update UI
  - But server has final say on valid moves
- **Deterministic**: Same inputs = same outputs (for testing)
- **Edge Cases**: Handle ALL scenarios defined in PRD section 3.3
  - Blocked squares must allow at least one winning line
  - Gravity Well self-sabotage detection
  - Ultimate Mode wildcard rules
  - Spinner with <2 available squares

### Modifiers Implementation Priority
1. **MVP**: Blocked Squares, The Spinner (Phase 1)
2. **Post-MVP**: Gravity Well, Volatile Squares (Phase 8)
3. **Advanced**: Ultimate Mode (Phase 8)

DO NOT implement #2 or #3 until #1 is complete and tested.

### Real-Time Considerations
- Handle network latency gracefully
- Implement reconnection logic
- Show clear "waiting for opponent" states
- Timeout disconnected players after 30 seconds

---

## 🚀 MVP Focus Areas

### What to Prioritize (Phases 0-4)
✅ Core 3x3 Tic-Tac-Toe gameplay
✅ Matchmaking (basic FIFO queue)
✅ Two simple modifiers (Blocked Squares, Spinner)
✅ Real-time multiplayer
✅ Basic authentication
✅ Win/Loss/Draw detection
✅ Essential UI (Home, Game, End screens)
✅ Unit + Widget tests

### What to Defer (Phases 5-8)
❌ Social sharing / viral features
❌ Leaderboards
❌ Store / Monetization
❌ Advanced modifiers (Gravity Well, Ultimate Mode)
❌ Daily rewards
❌ Friend system

### What NOT to Build Yet (Phase 9+)
❌ Tournaments
❌ Ranked mode
❌ 2v2 modes
❌ Chat system
❌ Clans/Groups

---

## 🎨 UI/UX Guidelines

### Design Principles
1. **Clarity**: Users should instantly understand what to do
2. **Delight**: Add personality through animations and interactions
3. **Speed**: Fast interactions, no unnecessary waits
4. **Consistency**: Reuse design patterns across screens

### Screen-Specific Requirements

**Home Screen**:
- Giant "PLAY" button (primary CTA)
- Quick access to profile (top corner)
- Unobtrusive access to store/settings
- Show current win streak prominently

**Game Screen**:
- 3x3 grid dominates the screen
- Clear turn indicator (whose turn it is)
- Opponent info visible but not distracting
- Modifier explanation accessible but not blocking

**End Screen**:
- Immediate feedback (WIN/LOSE/DRAW in large text)
- Celebration animation for wins
- Quick rematch button
- Option to return to menu

### Animation Standards
- **Duration**: 200-400ms for most interactions
- **Easing**: Use Flutter's Curves.easeInOut or Curves.elasticOut
- **Purposeful**: Every animation should have a reason
- **Skippable**: Long animations can be tapped to skip

### Color & Typography
- Define in theme, never hardcode
- Maintain consistent visual hierarchy
- Test in both light and dark mode
- Ensure readability on small screens

---

## 📊 Analytics & Monitoring

### Track These Events
- `match_start` (with modifier type)
- `match_end` (result, duration, modifier)
- `modifier_played` (which modifier was used)
- `screen_view` (navigation tracking)
- `error_occurred` (crash debugging)

### DO NOT Track
- Personally identifiable information (PII)
- Exact location data
- User messages or chat (if implemented)

---

## 🔒 Security Requirements

### Client-Side
- Never trust client input for game state
- Validate all user actions locally before sending
- Store auth tokens securely (flutter_secure_storage)
- No API keys in source code (use environment variables)

### Server-Side
- Validate ALL moves server-side
- Rate limit API calls
- Sanitize all inputs
- Use proper authentication for all endpoints

---

## 🐛 Debugging & Error Handling

### Error Handling Strategy
- **User-Facing**: Friendly messages, suggest actions
  - Bad: "Error 500: Internal Server Error"
  - Good: "Oops! We couldn't connect. Try again?"
- **Developer-Facing**: Detailed logs with context
  - Include: timestamp, user ID, action attempted, error details
- **Graceful Degradation**: App shouldn't crash, show fallback UI

### Common Scenarios to Handle
- Network disconnection mid-game
- Opponent disconnects
- Server is down
- Invalid game state received
- Authentication expired

---

## 📝 Documentation Requirements

### When to Update Docs
- After adding a new feature → Update README
- After making architectural decision → Create ADR (Architecture Decision Record)
- After completing a phase → Update `development_process.md`
- After discovering an edge case → Document in code comments

### What to Document
- Setup instructions (how to run the project)
- Architecture diagrams (if creating new patterns)
- API contracts (endpoints, payloads, responses)
- Complex algorithms (game logic, modifier rules)
- Known issues and workarounds

---

## ✅ Definition of Done

A task is NOT complete until:
- [ ] Code is written and follows style guide
- [ ] Tests are written and passing (unit + widget)
- [ ] Linter shows 0 errors
- [ ] Documentation is updated (if needed)
- [ ] `development_process.md` checkbox is marked complete
- [ ] Code has been reviewed (or you've done self-review)
- [ ] Tested on both iOS and Android (for UI features)

---

## 🚫 What NOT to Do

### Code Anti-Patterns
- ❌ No `print()` statements in production (use proper logging)
- ❌ No hardcoded strings (use localization keys)
- ❌ No magic numbers (define named constants)
- ❌ No god objects (classes >300 lines need refactoring)
- ❌ No commented-out code (delete it, git remembers)

### Development Anti-Patterns
- ❌ Don't skip tests "to move faster" (you'll move slower later)
- ❌ Don't commit broken code "to save progress" (use git stash)
- ❌ Don't implement features not in the PRD without asking
- ❌ Don't optimize prematurely (make it work, then make it fast)
- ❌ Don't copy-paste code (extract shared logic)

### Communication Anti-Patterns
- ❌ Don't assume requirements (ask for clarification)
- ❌ Don't silently change specs (discuss with developer)
- ❌ Don't hide blockers (communicate issues early)

---

## 🎯 Quick Decision Tree

### "Should I implement this feature?"
```
Is it in tech_prd_1_0.md or tasks_breakdown.md?
├─ YES → Is it in the current phase of development_process.md?
│         ├─ YES → Implement it! ✅
│         └─ NO → Wait for that phase
└─ NO → Ask the developer first! 🛑
```

### "Should I ask or just do it?"
```
Is the requirement crystal clear?
├─ YES → Do it! ✅
└─ NO → Ask first! 🛑

Do I need to make a technical choice?
├─ YES → Ask for preference 🛑
└─ NO → Follow established patterns ✅

Is this a UI/UX decision?
├─ YES → Propose options 🛑
└─ NO → Follow guidelines ✅
```

---

## 📞 When in Doubt

**ALWAYS prefer asking over assuming.**

A good question prevents hours of rework. The developer wants you to ask!

Examples of questions to ask:
- "I see the PRD mentions leaderboards, but I'm in Phase 1 (MVP). Should I skip this for now?"
- "The matchmaking logic isn't specified. Should I use ELO or simple FIFO?"
- "The color scheme isn't defined. Do you have a design system or should I create one?"
- "Should we handle the case where both players disconnect simultaneously?"

---

## 🎉 Summary: Your Mission

1. ✅ Build a beautiful, bug-free multiplayer Tic-Tac-Toe game
2. ✅ Follow the development process strictly (phase by phase)
3. ✅ Only build what's in the PRD (no scope creep)
4. ✅ Ask when confused (better safe than sorry)
5. ✅ Create delightful UX (smooth, fast, intuitive)
6. ✅ Write clean, tested, maintainable code
7. ✅ Update docs as you go (especially development_process.md)
8. ✅ Have fun building something awesome! 🚀

---

**Remember**: This game's success depends on a solid MVP first, then viral features. Quality > Speed. User Experience > Feature Count.

Let's build something amazing! 💪

