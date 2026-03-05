# NeuroLoad — NEXT UP
**The single file to open when resuming work. Updated after every sprint.**
**Last Updated:** 2026-03-05 (Sprint 4 complete)

---

## Current State in One Sentence

All 32 MVP stories are code-complete. The bottleneck is deployment and beta validation, not code.

---

## What to Do Right Now (Before Any New Code)

These are not optional. Do them in this order:

| # | Task | Time | Blocking |
|---|------|------|---------|
| 1 | **Deploy Stripe** — follow `planning/S4-001-STRIPE-SETUP.md` | 2–4 hours | All revenue |
| 2 | **Register deep-link** `neuroload://` in AndroidManifest + Info.plist + wire `app_links` in `main.dart` | 2 hours | Post-payment redirect |
| 3 | **Beta test with 50 users** — target NPS > 35 | 1–2 weeks | App Store submission |
| 4 | **Legal review** — ToS, Privacy Policy, Impressum to a lawyer | ~€2k, run in parallel | App Store submission |
| 5 | **App Store submission** — frame as "timer + analytics tool", not a blocker | 2–3 weeks approval | Launch |

---

## Sprint 5 — Queued (Opens After First Real Stripe Payment)

| ID | Task | Effort | Priority |
|----|------|--------|----------|
| S5-001 | Sub-category auto-suggest (US 1.2) | 1 day | 🟡 P2 |
| S5-002 | Baseline aim +5% nudge on setup screen (US 1.3) | 1 day | 🟡 P2 |
| S5-008 | Dynamic pricing from Supabase (MVP.003.001) | 1 day | 🟡 P2 |
| S5-003 | Resilience KPI — modal-dismiss delta tracking (US 3.4) | 1.5 days | 🟡 P2 |
| S5-004 | Contextual Leak + Strategy Recommendations (US 4.4 + 4.5) | 1.5 days | 🟡 P2 |
| S5-005 | Danger Zone heatmap overlay (US 3.2) | 2 days | 🟡 P2 |
| S5-006 | Full i18n EN + DE (Bug 04) | 3 days | 🟢 P3 |
| S5-007 | iOS ActivityKit Live Activities (Bug 09) | 5 days | 🟢 P3 |
| S5-009 | Phase 2 Cloud Sync — full delta-sync | 12 days | 🔴 P1 (Phase 2 gate) |

**Sprint 5 total:** ~29 days

---

## Full Sprint History

| Sprint | Status | What shipped |
|--------|--------|-------------|
| Sprint 1–3 | ✅ Complete | All core timer, onboarding, dashboard, sensors, foreground service, DB, CI/CD |
| Sprint 4 | ✅ Complete | S4-001 Stripe (code), S4-002 Calibration test phase, S4-003 Settings persistence, S4-004 Font picker, S4-005 /timer guard, S4-006 Break notifications, S4-007 One More Rep nudge, S4-008 Ghost intent flash fix |
| Sprint 5 | ⏳ Queued | See table above |

---

## Where Everything Lives

| What you need | File |
|---------------|------|
| Full implementation status (every story, every bug) | `planning/IMPLEMENTATION_LOG.md` |
| What to do to go live with Stripe (step-by-step) | `planning/S4-001-STRIPE-SETUP.md` |
| All user stories with acceptance criteria | `planning/NEW_USER_STORIES_v2_PERSONAS.md` |
| Business model, personas, financial projections | `planning/NEW_PRD_v2_STRATEGIC.md` |
| High-level strategy + launch checklist | `planning/STRATEGIC_OVERVIEW.md` |
| This file (resume point) | `planning/NEXT_UP.md` |

---

## Open Gaps (Not Yet Scheduled)

These are known, intentionally deferred, and tracked in the Implementation Log:

| ID | Gap | Sprint |
|----|-----|--------|
| GAP-007 | Sub-category auto-suggest | S5-001 |
| GAP-008 | Baseline aim +5% on setup | S5-002 |
| GAP-009 | Resilience KPI tracking | S5-003 |
| GAP-010 | Danger Zone heatmap overlay | S5-005 |
| GAP-011 | Contextual Leak coach insight | S5-004 |
| GAP-012 | Strategy Recommendations | S5-004 |

---

## How to Update This File

After each sprint closes, update:
1. The "Current State in One Sentence" line
2. Move the completed sprint row in Sprint History to ✅
3. Update "What to Do Right Now" with the next gate
4. Move completed S5-xxx items out of the Sprint 5 table
5. Update the "Last Updated" date at the top
