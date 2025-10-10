# step_dreamflow.md — Plan to Complete Epic 1 (Game Rules Engine & Real-time Matchmaking)

## Guiding Principles
- Start every work session by reviewing `docs/development_process.md` to confirm the active phase and avoid skipping ahead, per `docs/AI_RULES_SUMMARY.md`.
- Update documentation and phase checkboxes immediately after each deliverable ships; keep tests, analyzer, and code quality clean before moving on.
- Stay within the Epic 1 scope listed in `docs/tasks_breakdown.md`; raise questions before diverging or when requirements are unclear.
- Prioritize UX polish, 60 FPS performance, and accessibility while implementing code, even for backend-driven features.

## Phase 0 → Prerequisites & Foundations
1. Audit Phase 0 checklist items that block Epic 1 (version control, CI/CD, linting setup, dependency strategy). Document any gaps and either resolve them or escalate.
2. Finalize decisions for backend provider (expected Firebase per plan) and real-time transport so matchmaking work in later phases can proceed without rework.
3. Ensure analytics/crash monitoring tooling plans exist (even if integration waits) so instrumentation hooks can be added when implementing matchmaking flows.
4. Record all outcomes in `docs/development_process.md`, marking completed checkboxes and noting open questions.

## Phase 1 → Core Architecture & Game Rules Engine
1. Implement the Clean Architecture skeleton (`core/`, `data/`, `domain/`, `presentation/`) plus routing, state management, and DI so gameplay modules have a stable foundation.
2. Design the Tic-Tac-Toe domain model: board representation, player turn tracking, move validation, and win/draw detection rules with accompanying unit tests.
3. Build the modifier abstraction layer (interfaces, factory, injection points) while keeping implementations stubbed for now; ensure tests verify extensibility.
4. Document architectural decisions (folder layout, patterns, naming) and update `docs/development_process.md` Phase 1 checkboxes once tests and analyzer pass.

## Phase 2 → Matchmaking & Real-Time Game Loop (Epic 1 Focus Only)
1. Define the matchmaking client service contract that will talk to the future backend (queue join/leave/status) and design UI state transitions (Searching → Opponent Found → Connecting).
2. Implement provisional client logic (mock services if backend unavailable) to exercise the game loop end-to-end, including error handling and user feedback.
3. Integrate the real-time game state updates within the presentation layer, ensuring turn enforcement, move submission, and immediate board refresh.
4. Add instrumentation hooks (analytics events, logging) and comprehensive integration tests; finalize Phase 2 entries in `docs/development_process.md`.

## Phase 3+ → Out of Scope Notifications
- Stop at the completion of Epic 1 deliverables. Do not begin Epic 2+ tasks until directed; instead, prepare a summary of remaining dependencies (backend readiness, additional modifiers) for stakeholder review.

## Continuous Responsibilities
- Maintain >90% unit test coverage for game logic and add widget/integration tests as UI pieces land.
- Keep `docs/dreamflowrules.md` requirements visible; revisit after each milestone to confirm compliance.
- Surface blockers or ambiguities immediately via Dreamflow chat to enable quick stakeholder decisions.