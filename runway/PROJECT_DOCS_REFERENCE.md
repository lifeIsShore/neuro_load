# Project Documentation Reference
## What to Create, What It Contains, and Why — for Every Serious App Project

**Based on:** NeuroLoad Flutter app (2026)
**Applies to:** Any solo or small-team mobile/web app project
**Purpose:** Drop this into every new project. Never rebuild the doc structure from scratch.

---

## The Core Principle

Every document answers exactly one question.
If a document tries to answer two questions, split it.

| File | One Job | Who Reads It |
|------|---------|--------------|
| `planning/PRD.md` | What are we building and why? | Founder, AI assistant, new devs |
| `planning/USER_STORIES.md` | What does each user need to do? | Dev, QA |
| `planning/IMPLEMENTATION_LOG.md` | What is done, partial, or not started right now? | Dev — every session |
| `planning/bugs/bug_XX.md` | What exactly is broken and how to verify it's fixed? | Dev implementing the fix |
| `runway/GUIDE.md` | How do we build, deploy, and run CI/CD? | Dev, DevOps |
| `runway/AUDIT_REPORT.md` | What does the code actually do vs what we claimed? | Lead dev, before each sprint |
| `runway/SECRETS_CHECKLIST.md` | What credentials exist and where do they live? | Every dev onboarding |
| `runway/DECISIONS.md` | Why did we make each architectural choice? | Future you |
| `CHANGELOG.md` | What shipped in each public version? | Users, app store reviewers |
| `.env.example` | What environment variables does this app need? | Every dev |

---

## FILE 1 — `planning/PRD.md`
### Product Requirements Document

**One job:** Define the product at a business level. What problem, who has it,
what are the phases, what does success look like.

**Write it:** Day 0, before any code.

**What happens without it:** You build features that don't connect to a business
goal. You add Phase 4 features before Phase 1 is stable.
(NeuroLoad lesson: the original PRD listed 120+ stories with no priority.
It took a full rewrite to make it usable as a dev reference.)

```markdown
# [App Name] — PRD

## 1. Problem Statement
One paragraph. What is broken in the world that this fixes?

## 2. Target Personas
### Persona A — [Name]
- Who: ...
- Pain point: ...
- Goal: ...
- Willingness to pay: ...

## 3. Phases
### Phase 1 — MVP (target: [date])
Goal: [one sentence]
Must-have features: [3–5 bullets only]
Success metric: [one number — e.g. "100 paying users"]

### Phase 2 — Growth
Goal: ...

## 4. Explicit Out of Scope (Phase 1)
- [Feature X] — deferred to Phase 2
- [Feature Y] — not building at all
(This section prevents scope creep more than any rule or process.)

## 5. Revenue Model
How does this make money? When does the paywall trigger?
What is the pricing?

## 6. Constraints
Platform targets, budget, team size, hard deadline.
```

---

## FILE 2 — `planning/USER_STORIES.md`
### User Story List

**One job:** Every piece of user-facing behaviour as an acceptance-criteria-backed
story, grouped by epic, tagged by phase and effort.

**Write it:** After PRD is stable. Before any sprint planning.

**What happens without it:** Devs build features based on assumptions. QA has no
definition of "done." AI assistants can't implement correctly without criteria.

```markdown
# User Stories

## Epic 1 — [Name]

### US 1.1 — [Title]
As a [persona], I want [action] so that [outcome].

Acceptance Criteria:
- [ ] [Observable, testable condition]
- [ ] [Another condition]

Tasks:
- [ ] [Specific technical task]
- [ ] [Another task]

Effort: S / M / L / XL
Phase: 1 / 2 / 3
Depends on: US X.X (if any)
```

**Rules:**
- If you can't write acceptance criteria, the feature is not defined yet. Stop.
- Every story must be independently testable.
- Phase tag every story — otherwise everything feels equally important and nothing ships.

---

## FILE 3 — `planning/IMPLEMENTATION_LOG.md`
### The Living Status Board ← most important file in the project

**One job:** Ground truth for what is done, partial, or not started.
Read at the start of every dev session. Updated after every session.

**Rules that matter:**
- Only mark DONE after confirming the code exists in the actual file.
  "I think this is done" is not done.
- Every PARTIAL row must name the exact missing piece, not just say "partial."
- A dedicated Audit / Silent Gaps section must exist and be kept current.
- Stale entries are worse than no entries — they create false confidence.

```markdown
# Implementation Log
Last Updated: [date] ([what changed this session])

## Legend
✅ DONE      — source-verified, fully working
🔨 PARTIAL   — shell exists; [specific named thing] is missing
❌ NOT STARTED
🔒 BLOCKED   — waiting on [named prerequisite]
⚠️ STALE    — written against a design that no longer exists

---

## Epic 1 — [Name]

| Story | Title | Status | Source-Verified Notes |
|-------|-------|--------|-----------------------|
| US 1.1 | Login | ✅ DONE | `auth_service.dart` — `signIn()` + token stored in SecureStorage |
| US 1.2 | Auto-suggest | 🔨 PARTIAL | TextField exists. DB history query not implemented. See Sprint 3. |
| US 1.3 | Offline mode | ❌ NOT STARTED | |

---

## Bug Fix Log

| Bug | Title | Status | Method |
|-----|-------|--------|--------|
| Bug 01 | Crash on empty state | ✅ FIXED | Null check added in `session_provider.dart:finishSession()` |
| Bug 02 | Score inflation | ✅ FIXED | `durationMultiplier` applied to raw score for sub-5-min sessions |
| Bug 03 | Pause logic | ⚠️ STALE | No pause feature exists. Closing as WONTFIX. |

---

## Audit — Silent Gaps
(Things that exist in USER_STORIES.md but were never tracked here)

| ID | Gap | Exact File | Priority |
|----|-----|------------|----------|
| GAP-001 | Settings lost on restart — provider is in-memory only | `providers/settings_provider.dart` | 🔴 P1 |
| GAP-002 | Font picker tile `onTap: () {}` — no picker UI | `screens/settings_screen.dart` ~line 195 | 🔴 P1 |

---

## Stale Log Entries — Corrected
(Old entries that claimed DONE/gap but were wrong)

| Old Entry | Was Claimed | Reality |
|-----------|-------------|---------|
| "Heatmap is daily grid" in gaps table | 🔴 HIGH gap | ✅ Fixed in Sprint 2 — CircularHeatmap done |

---

## Sprint N — Current Target

### SN-001 — [Task name]
Effort: [X days]   Blocks: [what this unblocks]

| Task | File | What to do |
|------|------|------------|
| A | `lib/screens/paywall_screen.dart` | Wire "Buy Now" onTap → POST to edge function → launchUrl |
| B | `lib/providers/subscription_provider.dart` | Poll isPaidProvider every 3s for 60s after launch |

Acceptance criteria: [what done looks like, testable]

---

## Sprint N+1 — Queued

| ID | Item | Effort |
|----|------|--------|
| S[N+1]-001 | [description] | 1 day |
```

---

## FILE 4 — `planning/bugs/bug_XX_short_name.md`
### One File Per Bug

**One job:** All context for a single bug. Enough for anyone (or an AI) to implement
the fix with zero additional questions.

**Why separate files, not a list:** A list can't hold the full context needed to
implement a complex fix two weeks later without re-reading chat history.

```markdown
# Bug XX — [Short Name]

## Description
As a [user], I want [behaviour] so that [goal].

Problem: [what is currently happening, with specific context]

## Steps to Reproduce
1. ...
2. ...
3. Observe: ...

## Expected vs Actual
Expected: ...
Actual: ...

## Acceptance Criteria
- [ ] [Testable condition that proves it's fixed]
- [ ] [Another condition]

## Resolution / Solution Method
(Fill in after fix)
Files changed:
- `lib/x.dart` — [what was changed]
Method: [one sentence describing the approach]

## Status
❌ Open / 🔨 In Progress / ✅ Fixed
```

**NeuroLoad lesson:** 11 bug files were created upfront with full acceptance criteria.
This let an AI implement each one precisely. The one bug WITHOUT criteria (Bug 03 Pause Logic)
turned out to be stale — writing the criteria revealed the feature never existed.

---

## FILE 5 — `runway/GUIDE.md`
### Engineering Operations Guide

**One job:** Everything a dev needs to set up the project, understand the pipeline,
and know what's next. "How we build" — not "what we build."

**Write it:** Before the first CI workflow. Ops docs written retroactively are always
incomplete because the person writing them has forgotten the pain points.

```markdown
# [App] — Engineering Guide

## 1. Repo & Branch Strategy
- `main` — protected, CI on every push
- `feature/*` — PR into main, 1 approval required
- `release/*` — RC branch, freeze for QA

## 2. CI/CD Pipeline

| File | Runner | Triggers | What it does |
|------|--------|----------|--------------|
| `ci_android.yml` | ubuntu-latest | push/PR to main | analyze, test, build APK + AAB |
| `ci_ios.yml` | macos-latest | push/PR to main | analyze, test, unsigned IPA |

## 3. Android Release Signing
Step-by-step keytool command.
key.properties format.
Which GitHub Secrets to add (names only, no values).

## 4. iOS Distribution
Apple Developer account checklist.
Certificate + provisioning profile steps.
TestFlight upload steps.

## 5. Local Dev Setup

| Tool | Version | Install |
|------|---------|---------|
| Flutter | 3.x.x | flutter.dev |
| Dart | 3.x.x | included |
| ... | | |

Commands:
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run

## 6. Code Generation
When: after changing any Drift table or adding a Riverpod provider annotation.
Command: `dart run build_runner build`
Files generated: `*.g.dart` (committed to repo)

## 7. Environment Variables & Secrets

| Secret | Used where | Required locally? |
|--------|------------|-------------------|
| KEYSTORE_BASE64 | CI only | No |
| STRIPE_PK | App at build | Yes |

## 8. Definition of Done
Every PR must pass before merge:
- [ ] `flutter analyze` zero warnings
- [ ] `flutter test` all passing
- [ ] IMPLEMENTATION_LOG.md updated
- [ ] New story rows are source-verified

## 9. Implementation Backlog
[Summary table — full detail in planning/IMPLEMENTATION_LOG.md]
```

---

## FILE 6 — `runway/AUDIT_REPORT.md`
### Source-Verified Audit

**One job:** At least once per phase, read the actual source files and verify
that what the implementation log claims is true. Write the discrepancies down.

**Write it:** Before each sprint planning session, or after any pause longer
than two weeks.

**Why it matters:** Logs drift. Features get claimed as done but are wired to
a dead code path. Silent gaps accumulate. An audit forces honest accounting
and prevents the team from planning on top of a false foundation.

```markdown
# Audit Report — [Date]

## Section 1 — Story Status (Source-Verified)
For each claimed-DONE story:
### US X.X — [Title]
- Code confirmed in: `file.dart` method `functionName()`
- Acceptance criteria met: [which ones]
- Still missing: [anything left]

## Section 2 — Silent Gaps
Stories in USER_STORIES.md with zero code and zero log entry.

| Story | Title | What's needed |
|-------|-------|---------------|

## Section 3 — Stale Log Entries
Log entries claiming DONE/gap that are factually wrong.

| Log Entry | Claimed | Reality |
|-----------|---------|---------|

## Section 4 — Priority Summary

| Item | True Status | Priority |
|------|-------------|----------|
```

**NeuroLoad lesson:** Audit found 12 silent gaps and 5 stale log entries that had been invisible
for multiple sprints. Three stale entries were in the "gaps" table — meaning solved problems
were being treated as open blockers every session.

---

## FILE 7 — `runway/SECRETS_CHECKLIST.md`
### Credential Setup Checklist

**One job:** Name every secret, key, and credential the project needs — and where
each one lives. A checklist, not a values file.

**Never store actual secret values in this file. Names and locations only.**

```markdown
# Secrets Checklist

## Android Release Signing
- [ ] `release.jks` created
      Command: keytool -genkey -v -keystore release.jks ...
- [ ] Backed up to [password manager name]
- [ ] KEYSTORE_BASE64 → GitHub Secrets (Settings > Secrets)
- [ ] KEY_ALIAS → GitHub Secrets
- [ ] KEY_PASSWORD → GitHub Secrets
- [ ] STORE_PASSWORD → GitHub Secrets

## iOS Distribution
- [ ] Apple Developer account active
- [ ] Distribution certificate created + exported as .p12
- [ ] APPLE_CERTIFICATE_BASE64 → GitHub Secrets
- [ ] APPLE_CERTIFICATE_PASSWORD → GitHub Secrets
- [ ] Provisioning profile downloaded
- [ ] APPLE_PROVISIONING_PROFILE_BASE64 → GitHub Secrets
- [ ] APP_STORE_CONNECT_API_KEY_ID → GitHub Secrets

## Stripe
- [ ] Publishable key → GitHub Secret STRIPE_PUBLISHABLE_KEY
- [ ] Secret key → Supabase Edge Function secrets ONLY (never in app or CI)

## Supabase
- [ ] Project URL → entered by user in app Settings (not build-time)
- [ ] Anon key → entered by user in app Settings (not build-time)
- [ ] Service role key → Supabase Edge Functions only

## Local Machine
- [ ] flutter doctor shows all green
- [ ] flutter pub get succeeds
- [ ] dart run build_runner build succeeds
- [ ] .env file created from .env.example
```

---

## FILE 8 — `runway/DECISIONS.md`
### Architecture Decision Log (ADR)

**One job:** Record WHY each major technical decision was made.
Not what — the code shows what. Why.

**Write it:** 5 minutes per decision, any time you make a non-obvious choice.

**What happens without it:** Every non-obvious choice gets re-debated from scratch
when you return after two weeks, hand off to another dev, or continue with an AI.
The same 20-minute conversation happens again and again.

```markdown
# Architecture Decisions

## ADR-001 — [Technology Choice]
Date: [date]
Context: What problem needed solving.
Decision: What we chose.
Reason: Why this over the alternatives.
Trade-off: What we gave up.
Revisit if: [condition that would make us reconsider]

---

## ADR-002 — [Another Decision]
Date: [date]
Context: ...
Decision: ...
Reason: ...
Trade-off: ...
```

**Example entries for a Flutter app:**

```markdown
## ADR-001 — Drift over sqflite
Context: Needed local SQLite with type-safe queries and DAO pattern.
Decision: Drift (formerly Moor).
Reason: Compile-time query safety, code-gen for DAOs,
        clean Riverpod integration.
Trade-off: Requires build_runner. Generated files in repo.

## ADR-002 — SharedPreferences for session retry queue
Context: finishSession() can fail if Drift write fails.
         Need a fallback that survives a corrupt DB.
Decision: Queue failed payloads to SharedPreferences JSON.
Reason: SharedPrefs uses a separate file from Drift's SQLite.
        If the DB is corrupt, SharedPrefs still works.
Trade-off: 5MB size limit. Fine for one session payload.
```

**NeuroLoad lesson:** This file was never created. Several decisions had to be
re-explained from scratch across sessions — why `flutter_foreground_task` instead
of `workmanager`, why SharedPrefs for the retry queue. Each re-explanation cost
10–20 minutes.

---

## FILE 9 — `CHANGELOG.md`
### User-Facing Release History

**One job:** What changed in each public release, in plain language.
Written for users and app store reviewers, not developers.

**Write it:** As the last step before every release.

```markdown
# Changelog

All notable changes to [App Name] are documented here.
Format: Keep a Changelog (keepachangelog.com)

## [Unreleased]
### Added
- ...

## [1.1.0] — 2026-04-15
### Added
- Break notifications: chime at T-60s and session end
- "One More Rep" nudge when within 10% of personal best

### Fixed
- High contrast mode now persists across app restarts
- Calibration now includes a flip-to-confirm test step

### Changed
- Settings > Accessibility now includes a font picker

## [1.0.0] — 2026-03-20
Initial public release.
```

---

## FILE 10 — `.env.example`
### Environment Variable Template

**One job:** A committed file listing every environment variable the app needs,
with placeholder values and comments. Devs copy to `.env` and fill in real values.
`.env` is gitignored. `.env.example` is committed.

```bash
# .env.example
# Copy this file to .env and fill in real values.
# NEVER commit .env

# ── Stripe ──────────────────────────────────────────
# Publishable key only in the app. Secret key goes in
# Supabase Edge Function secrets, never here.
STRIPE_PUBLISHABLE_KEY=pk_test_replace_me

# ── Supabase ─────────────────────────────────────────
# These are entered by the user in app Settings at runtime.
# They do NOT need to be set at build time.
# SUPABASE_URL=https://xxxx.supabase.co
# SUPABASE_ANON_KEY=eyJhbGci...

# ── Android Signing (CI only) ─────────────────────────
# These are injected by GitHub Actions via Secrets.
# You do not need them locally if running debug builds.
# KEYSTORE_BASE64=...
# KEY_ALIAS=...
# KEY_PASSWORD=...
# STORE_PASSWORD=...
```

---

## THE COMPLETE FOLDER STRUCTURE

Drop this layout into every new project on day one.

```
my_app/
│
├── planning/                         # PRODUCT layer — what we build
│   ├── PRD.md                        # Business-first product definition
│   ├── USER_STORIES.md               # Acceptance-criteria stories by epic
│   ├── IMPLEMENTATION_LOG.md         # ← most-read file in the project
│   └── bugs/
│       ├── bug_01_short_name.md
│       ├── bug_02_short_name.md
│       └── ...
│
├── runway/                           # ENGINEERING layer — how we build
│   ├── GUIDE.md                      # CI/CD, setup, secrets, branch rules
│   ├── AUDIT_REPORT.md               # Source-verified status, per sprint
│   ├── SECRETS_CHECKLIST.md          # Every credential — names only
│   └── DECISIONS.md                  # Why each architecture choice was made
│
├── .github/
│   └── workflows/
│       ├── ci_android.yml
│       └── ci_ios.yml
│
├── CHANGELOG.md                      # User-facing release notes
├── .env.example                      # Env var template (committed)
├── .env                              # Real values (gitignored)
├── .gitignore
├── README.md                         # 5-sentence project summary + quick start
│
└── lib/                              # Source code
    └── ...
```

---

## WHEN TO CREATE EACH FILE

| File | Create when | Update when |
|------|-------------|-------------|
| `PRD.md` | Day 0, before any code | Phase change, pivot decision |
| `USER_STORIES.md` | After PRD, before sprint 1 | New story discovered, effort re-estimated |
| `IMPLEMENTATION_LOG.md` | Before first line of code | Every single session |
| `bugs/bug_XX.md` | When bug is first found | When resolved — add resolution section |
| `runway/GUIDE.md` | Before first CI setup | New tool, new secret, new pipeline step |
| `runway/AUDIT_REPORT.md` | Before sprint 2 planning | Before each subsequent sprint |
| `runway/SECRETS_CHECKLIST.md` | When first secret is added | Every new credential |
| `runway/DECISIONS.md` | First non-obvious tech decision | Every new ADR |
| `CHANGELOG.md` | First public release | Every release |
| `.env.example` | When first env var is needed | Every new variable |

---

## THE THREE MOST IMPORTANT FILES

If you can only maintain three, make it these.

**1. `planning/IMPLEMENTATION_LOG.md`**
Every session starts by reading this. If it's stale, every session starts with
archaeology. If it's accurate, you start building in two minutes. The ROI on
keeping this current is higher than any other doc in the project.

**2. `runway/GUIDE.md`**
Every new environment — new machine, new dev, new CI runner — needs this.
Without it you excavate old chat logs to find the keystore command you ran
six months ago. One hour to write, saves five hours per new setup.

**3. `runway/DECISIONS.md`**
The invisible one that costs the most when missing. Every architectural
decision not recorded here gets re-debated from scratch when you return after
two weeks, bring in a new dev, or continue with an AI assistant. It compounds.

---

## THE MOST COMMON MISTAKES

**Marking things DONE from memory instead of source.**
Open the file. Confirm the function exists. Then mark it done.
"I think we built this" has caused more sprint planning failures than anything else.

**One giant PRD with no phase separation.**
When everything is in Phase 1, nothing is in Phase 1.
The Out of Scope section is the most underrated doc technique that exists.

**Bug files without acceptance criteria.**
A bug without criteria is a complaint, not a task.
You cannot verify it's fixed, and you cannot hand it to anyone else.
If you can't write the criteria, the bug is not yet defined.

**No DECISIONS.md.**
Every non-obvious choice re-litigated from scratch, every session, forever.
Five minutes to write. Pays for itself in the first week.

**Secrets in chat history instead of SECRETS_CHECKLIST.md.**
Credentials get lost. You regenerate them, breaking old installs.
Or worse, you find the Supabase URL by reading 200 messages of chat history.

**Audit skipped before sprint planning.**
Planning on top of a stale implementation log means planning on top of fiction.
A 30-minute audit before each sprint finds the gaps before they become
mid-sprint surprises.
