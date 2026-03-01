PRD-flowstate: deep focus

This is a comprehensive Product Requirements Document (PRD) outline specifically tailored for NeuroLoad. It is structured to guide you from the initial "Vibe" and "Philosophy" through the deep technical architecture we discussed, all the way to the legal and marketing exit strategies.

1. Executive Summary
1.1. Product Vision & Mission
1.2. The "Popcorn Brain" Problem Statement
1.3. The Solution: Progressive Overload for Focus
1.4. Target Audience Personas (Students, Devs, ADHD High-Performers)
1.5. Key Value Propositions (One-Time Payment, Local-First, Gym-Mental)

2. Functional Requirements
2.1. The "Gym" (Focus Session Management)
2.1.1. Pre-Session Context Setup (Category & Sub-Category)
2.1.2. The Dynamic Flowtime Timer Engine
2.1.3. The "Lap" Trigger (Distraction Logging System)
2.1.4. Distraction Classification Modal (The 5-Second Auto-Dismiss)
2.1.5. Post-Session Analysis & Quality Scoring
2.2. The "Rest" (Recovery System)
2.2.1. The 20% Break Calculation Logic
2.2.2. Break Countdown & Completion Notifications
2.3. The "Dashboard" (Progressive Overload Analytics)
2.3.1. Daily/Weekly/Monthly Heatmaps
2.3.2. Focus Density & Recovery Resilience KPIs
2.3.3. Distraction "Trigger" Pie Charts
2.3.4. Personal Best (PB) Tracking (1-Rep Max Flow)
2.4. Smart Coach (ML Engine)
2.4.1. Baseline Calibration Logic
2.4.2. "Next Aim" Progressive Goal Generation
2.4.3. Contextual Weakness Insights (e.g., "Language vs. Math")

3. User Experience (UX) & Design
3.1. Design Language (The "Gym for the Brain" Aesthetic)
3.2. User Onboarding Flow (The 6-Step Indoctrination)
3.3. Mobile UI Specifications (Focus Mode & Haptics)
3.4. Desktop UI Specifications (Windows/macOS Adjustments)
3.5. Hardware Integration (Face-Down/Gyroscope Detection)
3.6. Lock Screen Widgets & Live Activities

4. Technical Architecture
4.1. The Tech Stack (Flutter, Drift, Supabase)
4.2. Data Architecture (Local-First Sync Engine)
4.3. Database Schema Design (SQL/SQLite)
4.3.1. User Profiles & Payment Metadata
4.3.2. Sessions & Laps Relational Mapping
4.4. Sync Strategy (PowerSync & Conflict Resolution)
4.5. Multi-Device Management (The "Single Active Session" Lock)

5. Security & Privacy
5.1. Data Encryption (SQLCipher AES-256)
5.2. Authentication & Secure Key Management
5.3. Supabase Row Level Security (RLS) Policies
5.4. GDPR Compliance Framework
5.4.1. Right to Erasure (Delete My Data)
5.4.2. Data Portability (CSV/JSON Export)

6. Monetization & Business Model
6.1. The "Early Bird Lifetime" Pricing Tiers
6.2. Stripe Integration & Webhook Handling
6.3. Tax-Deductible Invoice Generation System
6.4. B2B & Educational Partnership Portal Logic

7. Marketing & Growth
7.1. Ad Creative Strategy (TikTok/Shorts Explainer Hooks)
7.2. "Trusted Partner" Social Proof Strategy
7.3. Employer Reimbursement PDF Templates
7.4. App Store Optimization (ASO) Strategy

8. Legal & Compliance
8.1. Terms of Service (Medical Disclaimers)
8.2. Privacy Policy (Processor List)
8.3. Impressum (German Legal Compliance)
8.4. Return & Refund Policy

9. Roadmap & Expansion
9.1. Phase 1: Solo MVP (Core Timer + Local DB)
9.2. Phase 2: The "Caretaker" (Hire VA + Cloud Sync)
9.3. Phase 3: The "Owner" (Hire Dev + B2B Expansion)
9.4. Exit Strategy (Valuation & Acquisition Plan)
Appendix


Chapter 1. Executive Summary
This chapter defines the foundational "Why" behind NeuroLoad. It establishes the philosophical and psychological framework that differentiates this app from the thousands of "distraction blockers" currently on the market.

1.1. Product Vision & Mission
Vision: To transition the global digital workforce and student body from a state of "digital frailty" to "cognitive resilience." We envision a world where focus is viewed as a high-performance athletic skill rather than a disappearing resource.
Mission: To provide the most elegant, privacy-first, and scientifically grounded "Brain Gym" that empowers high-achievers to reclaim their deep work through the principle of progressive overload.

1.2. The "Popcorn Brain" Problem Statement
Modern digital environments have induced a physiological state known as "Popcorn Brain." Constant exposure to micro-content (TikTok, Reels, Slack) has rewired the brain to expect rapid stimulation.
The Core Issues:
Neural Fragmentation: The brain "pops" from one thought to another every 10–20 seconds, making sustained "Deep Work" impossible.
The Shame Cycle: Current productivity apps use "Digital Handcuffs" (blocking apps). When a user bypasses these blocks, they feel shame, leading to a total abandonment of the tool.
The "Cute" Fatigue: High-performers (CEOs, Engineers, Finance Students) are tired of "planting virtual trees" or "fighting dragons." They need a tool that respects their maturity and intellect.

1.3. The Solution: Progressive Overload for Focus
NeuroLoad borrows the most effective principle from strength training: Progressive Overload.
Instead of forcing a user to focus for 60 minutes on Day 1, NeuroLoad treats focus like a muscle:
Baseline Testing: The app measures the user's current "1-Rep Max Flow" (how long they can focus before a natural distraction occurs).
The Lap Mechanic: Every distraction is a "Rep." You don't fail when you get distracted; you simply log the "Lap" and restart the effort.
Incremental Resistance: The "Smart Coach" (ML) suggests adding 2–5% more duration to the next session based on previous "Resilience Scores."

1.4. Target Audience Personas
Persona
Motivation
Pain Point
The Master’s Student
Needs 4–6 hour deep-study blocks for complex topics (e.g., Finance/Law).
Limited budget; hates "renting" apps; needs tax-deductible tools.
The Senior Dev
Needs to enter "The Zone" for complex architecture/coding.
Despises bloatware, telemetry/tracking, and childish UI.
The ADHD High-Performer
Highly ambitious but struggles with executive dysfunction.
Feels "shame" when using rigid timers (Pomodoro); needs data-driven insights.


1.5. Key Value Propositions
1.5.1. One-Time Payment (The Anti-SaaS)
NeuroLoad is a permanent asset, not a monthly bill. We believe focus tools should be owned, not rented. This builds a deep, long-term relationship with the user.
1.5.2. Local-First (The Privacy Luxury)
In an era of data-harvesting, NeuroLoad is a fortress.
All focus logs, categories, and personal notes stay on the device.
Cloud Sync is an optional, encrypted convenience for paid members, not a requirement.
1.5.3. Gym-Mental Branding
The design language is Elegant Noir. It is "athletic" for the mind. It doesn't look like a toy; it looks like a precision instrument found on the desk of a 1960s architect or a Silver Age comic-book detective.

Next Step for the Captain:
With the Executive Summary complete, you now have the "North Star" for your branding.
Would you like me to create a "Technical Feature Map" that links these high-level visions to specific code modules? (e.g., How "Popcorn Brain" logic maps to the "Lap" trigger code).


Chapter 2. Functional Requirements (Comprehensive Detail)
This chapter serves as the precise engineering blueprint for the NeuroLoad application. It defines exactly how the "Gym" mechanics translate into user actions and system responses.

2.1. The "Gym" (Focus Session Management)
2.1.1. Pre-Session Context Setup (The "Weight Selection")
Mandatory Primary Category: Users must select one of five pillars: Study, Work, Creative, Admin, or Lifestyle.
Logic: This determines the "contextual baseline" for the ML Engine.
Dynamic Sub-Category Input: A clear, neat text field (max 30 characters).
Feature: Auto-suggests names from the top 5 most frequently used sub-categories within that Primary Category.
The "Baseline Aim": A toggle-based selector allowing the user to set a target for their 1-Rep Max (1RM) for this specific session.
UI: Displays the last 3 PBs (Personal Bests) for this category to nudge the user toward a 5% increase.
Start Modes: 1. Manual Start: Primary "Start Session" button.
2. Frictionless Start: Flip phone face-down (using Proximity/Gyroscope sensors).
2.1.2. The Dynamic Flowtime Timer Engine
The "Breathing" Ring: A central Ligne Claire circle that pulses at a rate of 6 cycles per minute (standard meditative breathing).
System Requirement: The pulse must remain constant even if the timer is in "Ambient Mode."
Ambient Display Logic: A double-tap on the center of the screen hides the numbers (mm:ss), leaving only the pulsing ring.
Goal: Reduces "Time-Urgency" stress and prevents dopamine-chasing by staring at the clock.
Haptic Milestones: A subtle, high-frequency haptic "tick" every 10 minutes to subconsciously signal progress without an audible alert.
2.1.3. The "Lap" Trigger (Distraction Logging)
Non-Interruptive Logic: The "Distracted" button is the largest touch target on the screen (minimum 88px height).
Interaction Flow:
User clicks "Distracted."
Immediate Haptic Feedback: A heavy "Thud" vibration.
Background Action: The system creates a Lap object linked to the SessionID, recording the StartTime (Session clock) and AbsoluteTime (System clock).
Continuous Counter: The main timer never stops. This reinforces the psychological principle that a distraction is a part of the session, not the end of it.
2.1.4. Distraction Classification Modal (The "Mental Check-in")
Trigger: Appears immediately after the "Lap" trigger is activated.
The 5-Second Auto-Dismiss Rule:
Phase 1: Modal opens with 6 icons (Phone, Hunger, Noise, Internal, People, Bio/Thirst).
Phase 2: A visual "fading progress bar" at the bottom of the modal counts down from 5 seconds.
Phase 3: If no selection is made, the modal closes and tags the lap as "Involuntary/Unknown."
Text Field: An optional field appearing only if an icon is selected, restricted to 4 words (e.g., "Thought about groceries," "Neighbor started drilling").
2.1.5. Post-Session Analysis & Quality Scoring
Session Termination: Triggered by flipping the phone face-up and holding a "Finish" button for 2 seconds (to prevent accidental stops).
Automated Scoring Formula:
$$Quality Score = (Focus Density \times 0.6) + (Resilience Score \times 0.4)$$
The "After-Action Report": Displays the session 1RM, total laps, and the primary "Focus Killer" identified by the system.
2.1.5.1. The "Zombie Session" Guardrail (Data Integrity):
The Problem: Users may start a session and leave the device unattended for extended periods (e.g., forgetting the phone in a drawer).
The Logic: If no "Lap" trigger, motion, or heartbeat activity is detected for 120 continuous minutes, the system initiates an Automatic Session Cap.
User Flow: Upon the next app open, a "Recovery Modal" appears: "We noticed a long period of inactivity. Was this a deep focus session, or did you forget to stop the clock?"
Requirement: The user must manually confirm the "Actual End Time" before the session is saved to the DB to prevent outlier data from skewing the Focus Density and 1RM KPIs.


2.2. The "Rest" (Recovery System)
2.2.1. The 20% Break Calculation Logic
Dynamic Earning: Breaks are earned in "Laps."
Example: If your last continuous focus lap was 50 minutes, you earn a 10-minute "High-Quality Break."
Anti-Burnout Cap: * Minimum: Sessions < 10m earn 0m break.
Maximum: No single break exceeds 30m, regardless of session length.
Compound Logic: If a session has multiple laps, the break is calculated based on the average lap length to prevent "prying" for a long break after one lucky long lap.
2.2.2. Break Countdown & Completion
Visual Shift: The UI transitions from Obsidian Noir to Mid-Century Teal/Sage.
Notifications: * A "Soft Wake" sound (low-frequency chime) at T-minus 60 seconds.
A "Ready to Train" notification when the break expires.
The "One More Rep" Nudge: If a user tries to end a focus session at 16 minutes, and their 1RM is 20 minutes, the app displays: "You are 4 minutes away from your best. Push for the 1RM?"
 ensure the "Ready to Train" notification is not a persistent buzz. Use a "Single, Elegant Chime" to maintain the "Classy" vibe.

2.3. The "Dashboard" (Progressive Overload Analytics)
2.3.1. Daily/Weekly/Monthly Heatmaps
Focus Density Map: A 24-hour circular heatmap showing when the user's focus is most "dense."
Distraction Density Map: Identifies "Danger Zones" (e.g., "You are 4x more likely to be distracted by your phone between 8:00 PM and 10:00 PM").
2.3.2. Focus Density & Resilience KPIs
Density: The percentage of the session spent in "Deep Flow" (Active timer minus recovery windows).
Resilience: The average time (in seconds) it takes the user to close the Classification Modal and return to focus. Lower = Better.
2.3.3. Distraction "Trigger" Pie Charts
The "Why" Breakdown: A pie chart showing the percentage of distractions caused by Internal vs. External factors.
Category-Specific Triggers: Allows filtering (e.g., "What distracts me most when I am in the 'Creative' category?").
2.3.4. Personal Best (PB) Tracking
The 1-Rep Max (1RM): The "Gold Standard" metric. The longest single span of focus without a "Lap" trigger.
Historical Trophies: A "Trophy Room" UI showing the date and category of the top five 1RMs ever achieved.

2.4. Smart Coach (ML Engine)
2.4.1. Baseline Calibration Logic
The "Silent Week": For the first 7 days, the app does not offer advice. It builds a "User Profile Matrix" based on:
Average Lap Length.
Most frequent category.
Peak resilience hours.
2.4.2. "Next Aim" Progressive Goal Generation
Overload Algorithm: * If current 1RM >= Baseline for 3 consecutive sessions $\rightarrow$ Suggest +5% duration.
If Density < 60% for 3 sessions $\rightarrow$ Suggest a "De-load Week" (Shorter target sessions to rebuild confidence).
2.4.3. Contextual Weakness Insights
Cross-Category Comparison: The engine identifies "Contextual Leaks."
Insight: "Your 1RM in 'Admin' is 45m, but only 12m in 'Language.' Consider using the 5-minute 'Warm-up' mode for Language sessions."
Time-Block Recommendations: "You achieve your highest Resilience Scores on Tuesday mornings. Schedule your most difficult 'Study' tasks then."
2.4.4. Circadian Rhythm Integration.
Why: A "Gym" doesn't just tell you how much to lift; it tells you when you are strongest. The app should map Focus Density against the time of day to tell the user: "Your biological prime time is 09:15 AM. Move your 'Deep Work' sessions here for a 15% density boost."
2.4.5.The "Task Intent" Ghost (Functional Addition)
The Gap: Users often enter a session and then get distracted by deciding what to do.
The Feature: Pre-Flow Intent Statement. Before the timer starts, the user must type one single sentence: "I will complete the UI wireframes." * Why: This creates a "Micro-Contract." If they hit the Lap trigger, the app subtly displays that sentence to remind them of their "Mission."



Chapter 3. UX & Design (The "Gym for the Brain" Aesthetic)
This chapter defines the visual soul and interaction model of NeuroLoad. The goal is a UI that feels like a high-end vintage training manual—sophisticated enough for a CEO, yet functional for a student.
3.1. Visual Identity & Color Palette
We avoid "gamer" neon. We use a palette inspired by 1950s architectural prints and Noir cinema to achieve an "elegant but not arrogant" look.
Element
Color Name
Hex Code
Purpose
Primary BG
Obsidian Noir
#1A1A1B
Deep, matte black for maximum focus.
Paper Surface
Vintage Cream
#F4F1EA
High readability; "classy" physical feel.
Primary Accent
Mid-Century Teal
#2D5D62
Professional color for primary actions.
Action/Alert
Crimson Noir
#A32626
For the "Distracted" button and alerts.
Data/Detail
Silver Age Gray
#8E8E93
For secondary text and Ligne Claire outlines.

3.2. Typography & Illustration Guidelines
Typography (The Noir-Modern Mix):
Headlines: Futura or Montserrat Bold (Geometric, mid-century).
Interface: Inter or San Francisco (High-legibility, neutral).
Data: JetBrains Mono (Used for the timer to feel like a "precision instrument").
The "Ligne Claire" Illustration Style:
Outlines: Strong, continuous black outlines of equal width. No sketchy lines.
Shading: No gradients. Use Ben-Day dots or Risograph textures for shadows.
Anatomy: Realistic, proportional human figures (Silver Age style). No "chibi" features.
Texture: A subtle "Paper Grain" shader (2% opacity) overlaying the UI.
3.3. User Onboarding Flow (The 6-Step Indoctrination)
Onboarding is mandatory to establish the "Muscle" philosophy:
The Manifesto: One-screen introduction to the "Popcorn Brain" crisis.
The Lap Mechanic: Visual tutorial on why distractions are "reps," not failures.
Sensor Calibration: Guided setup for the "Face-Down" hardware trigger.
Intent Setting: First practice of the "Pre-Flow Intent Statement."
Baseline Test: A short 5-minute session to calculate the user's initial 1RM.
The Founder’s Oath: Final privacy overview (Local-first commitment).
3.4. Mobile UI & Haptic Specifications
3.4.1. The Chronometer (Main Timer):
Design: Large, centered count-up timer using monospaced digits.
The Ring: A thin Ligne Claire circle pulsing at 6 cycles/min (meditative breath).
Ambient Mode: Double-tap to hide digits, leaving only the pulsing ring to reduce time-anxiety.
3.4.2. The "Distracted" Button (The Heavy Rep):
Dimensions: Width: Screen - 40dp | Height: 88dp.
Haptics: iOS: heavy impact; Android: LONG_PRESS pattern. Mentally associated with a "dropped weight."
3.4.3. The Lap Feed:
Vertical timeline below the timer. Each distraction is a small "dot."
Interaction: Clicking a dot reveals the classification (e.g., "Phone - 12:04").
3.4.4. Experimental "Noir" Polish:
The Shader: A "Flicker & Dust" option. When a Personal Best is hit, the screen triggers a subtle 1950s film projector flicker effect.
3.5. Platform Adaptations (Desktop & Hardware)
3.5.1. Desktop UI Specifications (Windows/macOS):
The "Digital Flip": Desktop hardware cannot be flipped. Instead, the timer is triggered via a Global Hotkey or by placing the mobile device face-down next to the computer (synced via Supabase heartbeat).
3.5.2. Hardware Integration (The Face-Down Trigger):
Logic: proximity.isNear == true + gyroscope.z > threshold = Session Start.
Adaptive Polling: To save battery, sensor frequency drops to "Low Power" once a session exceeds 5 minutes.
3.6. Lock Screen Widgets & Live Activities
3.6.1. Platform Persistence:
iOS: Uses Live Activities and Dynamic Island to keep the timer active in memory.
Android: Uses a Foreground Service with a persistent notification ("Active Training Session").
Goal: Prevents the OS from killing the app during long-running sessions.
3.6.2. Haptic Pattern Library:
Session Start: Double-Success Tap ("Engine Start").
Session Finish: Ascending frequency pulse ("Achievement").
Distraction: Heavy Thud ("Dropped Weight").
Break Over: Tri-Pulse Soft ("Gentle Wake").


Chapter 3. UX, Design & Component Library
This chapter defines the visual soul and the physical "instrument feel" of NeuroLoad. Every component is designed to move beyond standard mobile UI, mimicking high-precision analog tools.
3.1. Visual Identity & The "Core Canvas"
The background is a textured surface mimicking heavy-weight cardstock.
Primary Surface: #1A1A1B (Matte Obsidian Noir).
Paper Surface: #F4F1EA (Vintage Cream) for primary light elements.
The Paper Grain Shader: A 2% opacity noise overlay fixed to the screen coordinates to soften digital glare.
Ligne Claire Bordering: All containers use a 1.5dp solid stroke in #8E8E93 (Silver Age Gray).
Depth: No drop shadows. Use "Offset Borders" (a secondary border shifted by 2px down/right) to signify elevation.

3.2. Primary Component: The "Chronometer" (Main Timer)
The central focus of the app, designed to anchor attention without inducing "clock-watching" anxiety.
The Focus Ring: 280dp diameter. 4dp stroke with "Round" caps.
Motion: Continuous Sine curve opacity animation (100% $\rightarrow$ 85% over 10s).
The Digits: JetBrains Mono (Weight: 400). Kerning: 2.0.
Ambient Mode: Double-tap hides digits, leaving only the pulsing ring.
Accessibility: Screen readers announce milestones (e.g., "15 minutes elapsed") rather than every second.

3.3. Interaction Component: The "Lap" Trigger (Distracted Button)
The primary input for logging distractions. It must feel "heavy" and significant.
Dimensions: Width: Screen - 40dp | Height: 88dp.
Placement: Fixed at the bottom of the safe area for "thumb-reach" ergonomics.
States:
Idle: Crimson Noir outline (#A32626) with "Vintage Cream" ghost text.
Pressed: Solid Crimson Noir fill. Text flips to Obsidian Noir.
Logic: The session timer never pauses on click. This reinforces focus as a continuous journey.

3.4. Classification Component: The "Quick-Pills" Grid
Appears immediately after a Lap Trigger. Designed for sub-5-second interaction.
Grid: 2 columns x 3 rows.
Pill Style: 32dp Ligne Claire icons (Outline only). Label: Montserrat Regular, 12pt, uppercase.
The "Auto-Dismiss" Bar: A 2dp horizontal line at the bottom of the modal.
Animation: Width progresses $1.0 \rightarrow 0.0$ over 5000ms. If no icon is tapped by $0.0$, the modal closes and tags the lap as "Involuntary."

3.5. Feedback Component: The "Quality Score" Card
Presented in the post-session summary as a "Certificate of Training."
Seal of Quality: A Ben-Day dotted circular seal in the top-right corner.
The Logic: Displays the calculated Quality Score based on:
$$Quality Score = (Focus Density \times 0.6) + (Resilience Score \times 0.4)$$
Flicker Shader (Experimental): On hitting a Personal Best (PB), the card triggers a subtle 1950s film projector flicker effect.

3.6. Platform Logic & Persistence
Desktop (Windows/macOS): Since hardware cannot be flipped, use a Global Hotkey or "Digital Flip" (Timer starts when the synced mobile device is placed face-down nearby).
Live Activities (iOS): Anchor the timer to the Dynamic Island to prevent OS-level suspension.
Foreground Service (Android): Maintain a "Persistent Notification" to ensure the timer isn't killed during long-running sessions.

3.7. Haptic Pattern Library (The Pavlovian Language)
NeuroLoad uses distinct haptics to subconsciously train the user.
Action
Haptic Type
Mental Association
Session Start
Double-Success Tap
"Engine Start"
Lap Recorded
Heavy Impact (Thud)
"Dropped Weight / Rep Failed"
Session Finish
Ascending Success Pulse
"Mission Accomplished / Reward"
Break Over
Tri-Pulse Soft
"Gentle Wake"
New 1RM PB
Fireworks Pulse (Random)
"Elite Achievement"

.
Chapter 4. Technical Architecture

4.1. Core Tech Stack
Cross-Platform Framework: Flutter (Dart). Single codebase for iOS, Android, Windows, macOS, and Linux.
Local Database Engine: Drift (formerly Moor) + SQLite. Provides a reactive, type-safe SQL layer for Dart.
Cloud Backend (The Vault): Supabase (Postgres). Handles Authentication, Cloud Sync (for Paid Users), and Payment status.
Machine Learning Engine: TensorFlow Lite. Runs locally on-device to analyze focus patterns without uploading raw activity to the cloud.
State Management: Riverpod. Ensures a clean separation between UI and the focus logic.

4.2. Data Architecture (Local-First Sync Engine)
Offline-Primary Logic: The app must be fully functional without an internet connection. All writes occur in the local SQLite database first.
Delta Syncing: Only changed or new sessions/laps are pushed to Supabase when a connection is detected.
Conflict Resolution: "Last-Write-Wins" strategy based on a last_modified_at timestamp generated by the client.
The "Paid-Only" Bridge: Sync is triggered only if the profiles.has_paid flag is true in the Supabase Auth session.

4.3. Database Schema Design
4.3.1. Supabase (Cloud) / SQLite (Local) Tables
Table: profiles
Type
Description
id
UUID
Primary Key (Auth Link).
has_paid
Boolean
Access gate for premium features/sync.
active_device_id
Text
The "King of the Hill" lock for concurrency.
last_active_at
Timestamp
Heartbeat for the 10-minute timeout logic.
total_focus_mins
BigInt
Cached aggregate for global leaderboards.


Table: sessions
Type
Description
client_id
UUID
Primary Key (Client-generated for offline use).
category
Text
"Study", "Work", "Creative".
sub_category
Text
Free-text tag (e.g., "Math Exam").
start_time
Timestamp
Precise start of the flow session.
end_time
Timestamp
Nullable; updated when session concludes.
device_os
Enum
'ios', 'android', 'macos', etc.
quality_score
Integer
0-100 score (ML calculated).


Table: laps
Type
Description
client_id
UUID
Primary Key (Client-generated).
session_id
UUID
Foreign Key to sessions.client_id.
trigger
Enum
'phone', 'hunger', 'noise', 'daydream', etc.
note
Text
Max 4-word user input.
timestamp
Timestamp
When the distraction occurred.


4.4. Concurrency & Device Management
4.4.1. The "Single Active Session" Lock
Mechanism: An RPC (Remote Procedure Call) function in Supabase named attempt_start_session.
Logic:
Compare requested device_id with active_device_id in profiles.
If last_active_at > 10 mins ago, the lock is expired and granted to the new device.
If a session is active elsewhere, return a 403 Blocked response.
4.4.2. The Heartbeat System
While a session is active, the app sends a "Pulse" to Supabase every 5 minutes.
The pulse updates the last_active_at column.
This ensures that if the app crashes, the user is only "locked out" of other devices for a maximum of 10 minutes.
4.4.3.Battery Management & Sensor "Sleep" (Technical Architecture)
The Issue: Constantly polling the Proximity Sensor and Gyroscope (Section 3.5) for a 2-hour session can be a significant battery drain.
The Adjustment: Implement "Adaptive Polling." Once the "Face-Down" state is confirmed and the timer has run for > 5 minutes, the app should reduce the sensor polling frequency to "Low Power" mode, waking up only if a significant motion event is detected.


4.5. Security Implementation
4.5.1. On-Device Encryption
Encryption Standard: AES-256 via SQLCipher.
Key Storage: Encryption keys are generated upon the first install and stored in:
iOS: Keychain Services.
Android: Keystore System.
Desktop: OS-native secret storage.
4.5.2. Cloud Row Level Security (RLS)
Select/Update/Insert Policy: * auth.uid() == user_id
Global Lockdown: No public access to any table. All requests must be authenticated via Supabase JWT.


Chapter 5. Security & Privacy
This chapter outlines the "Hacker-Proof" and "Lawyer-Proof" protocols for NeuroLoad. Since the app handles health-adjacent productivity data and user notes, we must treat privacy as a core product feature.

5.1. On-Device Encryption (The Local Vault)
The local SQLite database must not be accessible to other apps or anyone who finds a lost device.
Standard: AES-256 Transparent Encryption using SQLCipher.
Flutter Implementation:
Integrate sqlcipher_flutter_libs to replace the standard SQLite driver.
Use PRAGMA key = 'passphrase'; immediately after opening the database.
Key Management (Zero-Trust):
The encryption key must never be hardcoded.
On the first run, the app generates a unique 64-character random string.
This key is stored in the Secure Enclave via flutter_secure_storage (iOS Keychain / Android Keystore).

5.2. GDPR "Right to Erasure" (The Kill Switch)
To comply with Article 17 of the GDPR, users must be able to completely vanish from your systems with one tap.
"Delete My Life" Protocol:
Cloud Wipe: The app calls a Supabase Edge Function using the service_role key to delete the user from auth.users. Due to On-Delete Cascade rules, all linked sessions, laps, and profiles in the Postgres DB are instantly purged.
Local Wipe: Upon confirmation from the cloud, the app executes File(dbPath).delete() and storage.deleteAll().
App Reset: The app restarts to the initial onboarding screen.

5.3. GDPR Data Portability (Export)
To comply with Article 20, users must "own" their data in a machine-readable format.
Implementation:
Format: A single .zip file containing neuroload_data.json and neuroload_stats.csv.
Generation: The app queries the local SQLite database, maps the rows to JSON objects using json_serializable, and uses the share_plus package to let the user save it to iCloud, Google Drive, or Email.

5.4. Backend Security (Supabase RLS)
We assume the client-side app can be hacked. Therefore, the Database itself must enforce security.
Row-Level Security (RLS) Policies:
Table sessions:
SQL
-- Only allow users to see their own focus sessions
CREATE POLICY "Users can only access own data" ON public.sessions
FOR ALL TO authenticated
USING (auth.uid() = user_id);




The "Payment Gate" Policy:
SQL
-- Block syncing if the user hasn't paid
CREATE POLICY "Sync only for paid users" ON public.sessions
FOR INSERT TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = auth.uid() AND has_paid = true
  )
);





5.5. Privacy-First "Shadow" Logs
No Metadata Leaks: The app must scrub any identifying info (like IP addresses or device names) before syncing focus sessions.
Local-Only Notes: A "Strict Privacy" toggle allows users to keep the notes column in the laps table local-only, meaning they are never uploaded to Supabase, even if cloud sync is active.

5.6. GDPR Compliance Summary Table
Requirement
Implementation
Status
Right to Access
Settings > Export Data (JSON/CSV)
✅ Planned
Right to Erasure
Settings > Delete Account (Cloud + Local Wipe)
✅ Planned
Data Minimization
No tracking of GPS, contacts, or photos.
✅ Hardcoded
Server Location
Supabase Project set to EU (Frankfurt).
✅ Fixed
DPA
Signed Data Processing Agreement with Supabase.
📝 Admin Task



Chapter 6. Monetization & Business Model (Deep Dive)
This chapter provides the technical and operational "playbook" for the NeuroLoad revenue engine. It is designed to be lean, automated, and compliant with both global standards and specific German regulations.

6.1. The "Early Bird Lifetime" Pricing Tiers
We utilize a Dynamic Scarcity Model. The system automatically tracks the global_user_count to adjust the price displayed on the landing page, creating authentic urgency.
Phase
User Cap
Price (One-Time)
Business Logic
Founder Batch
0 – 1,000
€14.99
Customer Acquisition Cost (CAC) focus. Low barrier to entry to flood the database with initial focus data for ML training.
Early Adopter
1,001 – 5,000
€24.99
Validation focus. Testing price elasticity. High-value "Early Bird" branding.
Standard Retail
5,001+
€49.99
Sustainability focus. Positioned against annual subscriptions (e.g., Opal at €60/yr). This becomes the "Anchor Price."


6.2. Stripe Integration & Webhook Architecture
To ensure the app remains Local-First but has Cloud-Verified status, we implement a robust webhook-to-edge-function pipeline.
6.2.1. The Payment Flow
Handshake: The Flutter app calls a Supabase Edge Function create-checkout-session.
Metadata Injection: The function passes the auth.uid() as client_reference_id to Stripe. This is the unbreakable link between the payment and your user.
Checkout: User is redirected to a Stripe-hosted page (PCI-compliant, handles 3D Secure).
6.2.2. The Webhook Security (The "Hacker-Proof" Part)
Signature Verification: The Edge Function handle-stripe-webhook must verify the Stripe-Signature header using your STRIPE_WEBHOOK_SECRET. This prevents "spoofing" (hackers sending fake "payment successful" messages to your server).
Idempotency: Every Stripe event_id is logged in a processed_events table. If Stripe sends the same "success" message twice, the second one is ignored.
Logic:
TypeScript
// Inside Supabase Edge Function
const { data: profile, error } = await supabase
  .from('profiles')
  .update({ has_paid: true, payment_id: session.payment_intent })
  .eq('id', session.client_reference_id);

6.3. Tax-Deductible Invoice Generation System
In Germany, a standard receipt is not enough for a student or professional to claim a tax deduction (Werbungskosten).
6.3.1. Automation Requirements
Stripe Tax: Enabled to automatically detect the user's location based on their IP/Credit Card and apply the correct VAT (e.g., 19% for Germany, 0% for US).
Dynamic Description: The invoice item must be titled: "NeuroLoad Focus Training - Professional Productivity Software License."
The "Kleinunternehmer" Clause: If you are under the €25k/year limit (as of 2025), your invoice must contain:
"Umsatzsteuerfrei aufgrund der Kleinunternehmerregelung gemäß § 19 UStG."
Delivery: Triggered via Resend API or Stripe’s native automation immediately after the webhook completes.

6.4. B2B & Educational Partnership Portal and Gift
This is a separate Next.js web dashboard for managers/teachers to buy "Seat Bundles."
6.4.1. Technical Specs
Seat Logic: A manager buys 50 seats. The organizations table in Supabase tracks total_seats vs used_seats.
Voucher Generation: The portal generates a cryptographically secure 8-character code (e.g., FOCUS-AX92-KLAU).
The "Claim" Logic:
In-app: User enters code.
Backend: Checks if code exists and used_seats < total_seats.
Result: Increments used_seats and sets user.has_paid = true.
6.4.2. Trusted Partner Display
Dynamic Logos: The landing page pulls logos from a partners table.
Verification: Logos only show once the Organization ID has at least 5 active users.
6.4.3. The "Gift of Focus" Engine
Goal: To leverage "Anti-SaaS" sentiment by allowing the upfront purchase of focus as a high-value digital gift.
The Philosophy: In a world of "subscription fatigue," a lifetime license is a prestigious gift. It represents a "Set-and-Forget" investment in someone’s cognitive health.
The Target: Parents of university students, partners of ADHD professionals, and managers of small creative teams.
Functional Mechanics:
The "Voucher-Card" Generation: Upon purchase, the giver receives a high-resolution, Noir-style digital certificate (PDF) with a unique 12-digit "Access Key."
Redemption Logic: The recipient enters the key in the app. The system checks the vouchers table in Supabase. If valid, it binds the has_paid flag to that User UUID and marks the voucher as "Consumed."
Revenue Impact: High upfront cash flow with zero churn risk. Unlike a subscription, there is no "cancellation" to manage.
Apple Reader App Rule: Be careful with the "Gift" engine on iOS. Apple may insist it goes through IAP. My advice: Sell the "Gifting Vouchers" primarily on your Web Dashboard, and allow recipients to "Redeem" in-app.

6.4.4. The B2B "Seat Reclamation" Protocol
Goal: To provide corporate managers and universities with control over their investment while respecting the user's privacy and effort.
The "Coach" Dashboard (Next.js): A portal for the purchaser (The "Coach") to manage their "Seat Bundle" (e.g., 50 seats for an engineering team).
The Reclamation Mechanic (Recycling):
The "Revoke" Button: If an employee leaves the company or a student graduates, the Manager can click "Revoke Seat" in the portal.
The Technical Handshake: 1. Supabase sets the has_paid flag for that specific User UUID to false.
2. The user's active_device_id is cleared from the cloud profile.
The "Local-First" Integrity (Crucial):
User Side: The user does not lose their data. Their years of "Focus Reps," 1RMs, and personal logs remain on their local device.
Restriction: The user simply loses access to "Cloud Sync" and "Team Lounges."
Outcome: This follows the "Gym" metaphor: You can lose your gym membership, but nobody can take away the muscles you already built.
Re-Issuance: The Manager now has 1 "Available Seat" in their bundle which can be issued to a new hire via a new voucher code.

6.4.5. Why this is a "Force Multiplier"
Feature
For the Manager (The Giver)
For the User (The Recipient)
Gifting
No hidden recurring costs; high perceived value.
Instant access to elite tools; no credit card required.
Recycling
The seat is an asset that can be used by 10 different employees over 10 years.
Privacy is guaranteed; their personal "Focus History" is never deleted by the boss.


6.4.6. The B2B Privacy Shield
 A "Zero-Knowledge" mode where the employer sees only aggregate focus hours for the team, but never individual lap triggers or private notes. This is crucial for German Work Councils (Betriebsrat).
Your B2B strategy is strong, but to sell to a German Mittelstand company or a University, you need a "Data Safety One-Pager."


6.5. Payment Implementation Checklist (Diligent Version)
Category
Component
Detail
Legal
TOS Link
Must be checked before Stripe redirect.
Tax
VAT OSS
Register for One-Stop-Shop if EU sales outside Germany exceed €10k.
Mobile
Apple IAP
Warning: Apple requires 15-30% cut for digital goods. Use "Reader App" logic or handle IAP + Web Checkout carefully.
Reliability
Retry Logic
If Supabase is down during a webhook, Stripe will retry for 3 days.
Administrative
Gewerbeamt
Ensure your Gewerbeanmeldung includes "Software Development & Sales."



Chapter 7. Marketing & Growth
This chapter outlines the strategy to acquire the first 5,000 users with a focus on "high-trust/low-cost" organic growth and strategic local partnerships.

7.1. The "Viral Loop" Content Strategy
In 2026, social media algorithms prioritize "Reali-TEA"—unfiltered, raw, and highly relatable content—over polished ads. Our strategy leans into the "Quiet Flex" and "Companion Content" trends.
7.1.1. TikTok & Reels Hooks (The Attention Grabbers)
The Loss Aversion Hook: "Stop using Pomodoro timers. They are actually breaking your flow state. Here’s the 2026 alternative."
The Curiosity Gap: "I spent 3 years at [University Name] struggling with ADHD until I realized focus isn't a gift, it's a muscle. Here’s how I 'weightlift' with my brain."
The Movement Hook: [Camera starts mid-action as you flip your phone face-down on a wooden desk] "The best focus app in the world is the one that forces you to ignore it. Let me show you why."
The "Quiet Flex": [Lo-fi video of a clean, aesthetic study setup with the NeuroLoad timer pulsing] "No subscriptions. No 'cute' trees. Just raw focus density."

7.2. The "Student Council" Partnership Script
This is your "Trojan Horse" for authority. Use this script to reach out to the Fachschaft (Student Council) or University clubs in Cologne.
Subject: Support for [University Name] Students: Free Focus Training Pilot
"Hi [Name],
I’m a Cologne-based developer (and local student/alum) building NeuroLoad, a new tool designed to help students fight 'popcorn brain' and reclaim their focus for exams.
Most apps today are expensive subscriptions. I want to do something different for our local community. I’d like to offer 100 free Lifetime Licenses (Value: €1,500) specifically for members of the [Council/Club Name] to use during this exam season.
In return, I’m just looking for a few students to give me honest feedback so I can keep building it for our needs. If this sounds like something your members would find useful, I can send over the access codes today.
Best,
[Your Name]"

7.3. "Social Media Hook" (Script for the Founder's Letter)
Use this script for a 30-second Reel/TikTok to drive traffic to the manifesto on your website.
Visuals: Handheld phone, walking through a park or sitting at a minimalist desk in Cologne.
Pacing: Fast cuts, text overlays.
0:00-0:03 (The Pattern Interrupt): [Point at the camera] "Stop renting your focus. You’re being charged €60 a year just to stay off your phone? That’s a scam."
0:03-0:10 (The Problem): "Most apps treat you like a child. They block your screen and hope for the best. But focus is a muscle—if you don't train it, it withers."
0:10-0:20 (The Reveal): "I built NeuroLoad to be a 'Gym for the Brain.' It's local-first, privacy-focused, and most importantly... it's a one-time purchase. No leeches, no subscriptions."
0:20-0:30 (The Call to Action): "I’m launching the first 1,000 'Founder' spots today for the price of a pizza. I wrote a letter about why I’m doing this and why the subscription model needs to die. Link in bio. Own your focus."

7.4. Growth Roadmap & KPI Tracking
7.4.1. Submission Safety & Language Guardrails:
Strategy: To mitigate Apple/Google rejection risks regarding "System Control," all store metadata must explicitly define NeuroLoad as a "Time-Management Instrument" or "Active Timer."
Constraint: Avoid using terms like "Phone Blocker," "App Restrictor," or "System Lock." Emphasize that the app relies on User-Initiated hardware triggers (Proximity/Gyroscope) rather than OS-level Screen Time API overrides.

Metric
Target
Method
Organic Reach
50k views/mo
3-5 Lo-fi "Study with Me" TikToks per week.
Partner Authority
3 Universities
Pilot programs with student councils in NRW.
Referral Rate
15%
"Gift a Friend" discount code for early birds.
CAC (Target)
< €4.00
Targeted Meta/TikTok ads using the highest-performing organic hooks.


7.5. Employer Reimbursement PDF (The Stealth Growth Tool)
A simple, professional one-pager users can download.
Section 1: "Why Deep Work is your company's most valuable asset."
Section 2: "How NeuroLoad increases 'Focus Density' by 22%."
Section 3: "The Cost: A one-time €14.99 fee (Cheaper than a single lunch)."


Chapter 8. Legal & Compliance
This chapter provides the formal legal framework for NeuroLoad. Given your location in Cologne and the nature of the app (focus/mental performance), these documents are designed to protect you from liability while ensuring full GDPR (DSGVO) compliance.

8.1. Terms of Service (Medical Disclaimers)
This section is your primary shield. It distinguishes "Productivity Training" from "Medical Treatment."
Medical Disclaimer & Limitation of Liability
No Medical Advice: NeuroLoad is a productivity tool, not a medical device. The "NeuroLoad" method, including "Progressive Overload" for focus, is a metaphorical framework for self-improvement and is not a clinical treatment for ADHD, Anxiety, Depression, or any other medical or mental health condition.
User Responsibility: Use of the App is at your own risk. We do not guarantee specific academic or professional results.
Not a Substitute: This App should not replace professional medical advice, diagnosis, or treatment. Always seek the advice of your physician or qualified health provider with any questions regarding a medical condition.
Assumption of Risk: By using NeuroLoad, you acknowledge that we (the developers) are not liable for any perceived lack of progress or performance in your personal or professional life.
8.1.1. Non-Restrictive Functionality Notice: > * NeuroLoad does not modify, restrict, or interfere with the device's Operating System or other installed applications. It is a standalone monitoring tool. The user maintains full control over their device at all times.

8.2. Privacy Policy (Processor List)
Because you are Local-First, your privacy policy is your strongest marketing asset. You must be transparent about where data "travels."
The "Local-First" Promise:
"We do not sell your data. We do not even see your focus logs unless you choose to enable Cloud Sync. Your personal notes stay on your device."
Authorized Data Processors
Under GDPR, you must list every third party that touches user data:
Processor
Purpose
Location
Data Handled
Supabase (AWS)
Database & Auth
Frankfurt, DE
Email, UUID, Encrypted Sync Logs.
Stripe
Payments
Global (EU/US)
Credit Card info, Billing Address, VAT ID.
Resend
Email Delivery
Global
User Email (for Invoices/Passcodes only).
Apple/Google
App Store Ops
Global
App Usage Statistics (Anonymized).


8.3. Impressum (German Legal Compliance)
As a business based in Cologne, you are legally required by § 5 TMG to provide an "Impressum." Failure to do so can result in an Abmahnung (legal warning).
Angaben gemäß § 5 TMG:
Betreiber: [Your Full Name]
Anschrift: [Your Street & House Number], [Zip Code] Köln, Germany
Kontakt: E-Mail: support@neuroload.com | Tel: +49 [Your Number]
Verantwortlich für den Inhalt nach § 55 Abs. 2 RStV: [Your Name] (Anschrift wie oben)
EU-Streitbeilegung:
Die Europäische Kommission stellt eine Plattform zur Online-Streitbeilegung (OS) bereit: https://ec.europa.eu/consumers/odr/. Wir sind nicht bereit oder verpflichtet, an Streitbeilegungsverfahren vor einer Verbraucherschlichtungsstelle teilzunehmen.

8.4. Return & Refund Policy
Since you are selling Digital Content, the rules are specific.
8.4.1. The EU Right of Withdrawal (Widerrufsrecht)
According to EU law, the 14-day right of withdrawal for digital content expires once the download or streaming has started, provided the user gave prior express consent.
Implementation: At the "Pay" screen, the user must check a box: "I agree to the immediate performance of the contract and acknowledge that I lose my right of withdrawal."
8.4.2. The "Founder’s Guarantee" (Your Policy)
To maintain the "Classy/Not Arrogant" vibe, we offer a 7-Day No-Questions-Asked Refund.
The Rule: If a user emails within 7 days of purchase, you refund the €14.99 manually via Stripe.
Why: It is better to lose €14.99 than to gain a 1-star review and a chargeback fee of €15.00.

8.5. Compliance Checklist for Launch
[ ] Checkbox at Checkout: "I have read the TOS and Privacy Policy."
[ ] PDF Storage: All invoices and legal versions are archived in Supabase for 10 years (German tax law requirement).
[ ] Cookie Consent: Not required! (Since you don't use tracking cookies, only essential "Local Storage" for the app to function).
This section is a legal and ethical requirement for any "Classy" product operating in the EU. In 2026, compliance with the European Accessibility Act (EAA) is no longer optional—it is a baseline for high-end software.
Here is the rewritten and expanded section for your PRD:

8.6. Accessibility & EAA Compliance (The "Inclusive Instrument")
Context: Under the European Accessibility Act (EAA), digital products must be perceivable, operable, and understandable by all users, including those with visual, auditory, or motor impairments. Compliance is mandatory for the EU market as of June 2025.
8.6.1. High-Contrast "Noir-White" Mode
The Problem: The standard "Obsidian Noir" (#1A1A1B) background may provide insufficient contrast for users with low vision or in high-glare environments.
The Solution: A dedicated High-Contrast Toggle in Settings.
Logic: Replaces Silver Age Gray (#8E8E93) with Pure White (#FFFFFF) or Absolute Yellow (#FFFD01) for all Ligne Claire outlines and text.
Visual Integrity: Maintains the "Noir" aesthetic by using stark, 100% contrast ratios (minimum 7:1) while preserving the thick black outlines.
8.6.2. Screen-Reader & VoiceOver Architecture
The Chronometer: The count-up timer must be accessible via Flutter Semantics.
Behavior: Instead of reading every second (which is distracting), the screen reader should announce focus milestones every 1 or 5 minutes (e.g., "Focus session active: 15 minutes elapsed").
Semantic Labeling: Every Ligne Claire icon (e.g., the 📱 for Phone or 🍔 for Hunger) must have a localized semanticLabel (e.g., "Distraction: Mobile Phone").
The "Lap" Feed: Distraction dots must be focusable elements that announce the time and category when selected.
8.6.3. Motor Impairment & Navigation
Target Size: All interactive elements, specifically the "Distracted" button and "Pill" icons, must maintain a minimum touch target of 48x48dp to accommodate users with tremors or motor control difficulties.
No-Gesture Fallbacks: While the "Face-Down" trigger is a core feature, a Manual Start/Stop fallback must always be accessible via a standard tap to ensure users with limited mobility can operate the app.
8.6.4. Dyslexia-Friendly Typography
Alternative Typeface: An option to switch the body text from Montserrat to OpenDyslexic.
Neatness Requirement: The layout must remain "classy" and avoid shifting elements when the font weight or spacing changes.
8.6.5. EAA Compliance Audit Trail
Requirement: Maintain an Accessibility Statement within the app's "About" section, detailing the current level of WCAG 2.1 Level AA compliance. This is a primary requirement for B2B sales to German Universities and Government-linked institutions.



Chapter 9. Roadmap & Expansion (The Exit Plan)
This chapter serves as your strategic "Flight Plan." It details the transition from a technical builder to a business owner, ensuring that every hour you spend coding today adds a multiplier to your future exit value.

9.1. Phase 1: Solo MVP (The Core Timer & Local DB)
Focus: Perfecting the "Feel" and the Philosophy.
Technical Milestones:
The "Lap" Engine: Implementation of the distraction logger that doesn't stop the clock.
Sensor Integration: Reliable "Face-Down" detection using the proximity/gyroscope API.
Data Integrity: Local-first persistence using Drift. Users must be able to use the app 100% offline.
Business Goal: 0 to 1,000 users.
Strategy: Manually recruit beta testers from your Master's program and local Cologne tech meetups. Get the first 50 "Love Letters" (testimonials) to prove the method works.
Success Metric: A retention rate where 30% of users open the app 4+ times a week.

9.2. Phase 2: The "Caretaker" (Automation & Cloud Sync)
Focus: Freeing your time and securing the revenue.
Technical Milestones:
The Supabase Bridge: Enable Cloud Sync for paid users.
Stripe Webhooks: Fully automated payment-to-access pipeline.
Invoice Engine: Automated PDF generation for tax-deductibility claims.
Staffing: * Hire 1: A Virtual Assistant (VA) for 5-10 hours/week.
SOP (Standard Operating Procedure): Create a document for the VA on how to handle "I forgot my password" and "Can I get a student discount?" queries.
Business Goal: 1,000 to 10,000 users.
Strategy: Launch on Product Hunt and start the TikTok "Study-with-Me" organic loop.
Success Metric: Positive ROI on ad spend (Spending €1 to make €3).

9.3. Phase 3: The "Owner" (B2B Expansion & Maintenance)
Focus: Scaling the asset and "Escaping" the code.
Technical Milestones:
B2B Dashboard: A separate web portal (Next.js) for managers/professors to manage seat licenses.
The "Pro" Layer: Introduction of a high-ticket subscription or an AI-Coaching add-on to establish recurring revenue (ARR).
Staffing:
Hire 2: A freelance Senior Flutter Developer on a monthly retainer (e.g., 20 hours/month).
Your Shift: You move 100% into Strategy, Marketing, and Partnership deals.
Business Goal: 10,000 to 100,000 users.
Strategy: Secure "Trusted Partner" status with at least 5 Universities/Consulting Firms.
Success Metric: Monthly profit exceeds €10,000 with less than 5 hours of your personal time required.

9.4. Exit Strategy (Valuation & Acquisition Plan)
The "Why": You sell when the capital can fund your next, even larger ambition.
Valuation Calculation:
SDE Multiple: For a solo-run one-time purchase app, expect 2.5x to 3.5x your annual profit.
ARR Multiple: If you successfully added the "Pro" subscription in Phase 3, your valuation jumps to 4x to 6x your annual recurring revenue.
The "Data Room" (Due Diligence Prep):
Clean Financials: Monthly P&L statements from the start.
Legal Moat: Evidence of trademark for "NeuroLoad" and signed DPAs with processors.
Tech Health: A documented API and a codebase that a new developer can understand in 48 hours.
Potential Buyers:
Micro-PE Firms: (e.g., WeCommerce or Tiny) who look for profitable, low-maintenance apps.
Strategic Buyers: EdTech companies (e.g., Coursera, Duolingo) or Health/Wellness brands (e.g., Headspace) looking for a "Focus" module to add to their suite.
Micro-Acquirers: High-net-worth individuals on Acquire.com looking for a "Cash Cow" business.

9.5. The Exit "Pro" Tip
The most valuable thing to a buyer isn't just your code—it's your Manual. If you can hand a buyer a "Key" and a "Book" (SOPs) that explains exactly how the VA and the Dev run the business without you, your valuation increases by 20% instantly. Classy businesses are organized businesses.

Chapter 10. Technical Feature Map
This chapter bridge the gap between your Vision (The "Why") and the Code (The "How"). It ensures that every line of Dart you write serves a specific psychological or business goal.

10.1. Philosophy-to-Module Mapping
Vision / Problem
Feature Solution
Technical Module / Code Implementation
"Popcorn Brain"
The Lap Trigger
DistractionStreamController: A Dart Stream that listens for tap events without stopping the Timer state.
Progressive Overload
Next Aim Logic
smart_coach_engine.dart: A service that compares the current session’s 1RM against a 7-day rolling average.
Anti-Shame Design
Non-Stopping Timer
FocusTimerBLoC: A state machine where the "Running" state is never interrupted by "Distraction" events.
Privacy Luxury
Encrypted Local DB
DatabaseModule: Drift integrated with SQLCipher for AES-256 on-device encryption.
Elite Branding
Noir UI Engine
ThemeRegistry: A custom Flutter ThemeData utilizing Risograph shader masks and Ligne Claire borders.


10.2. The Scoring Logic (The "Math" of Focus)
To provide the "Gym" feedback, we use a custom formula to calculate Focus Density ($FD$). This ensures users are rewarded for resilience, not just long hours.
$$FD = \left( \frac{T_{session} - \sum T_{recovery}}{T_{session}} \right) \times \left( 1 - \frac{N_{laps}}{H_{session}} \right)$$
$T_{session}$: Total duration of the session.
$T_{recovery}$: The time taken to classify a distraction and return to focus.
$N_{laps}$: Number of times the "Distracted" button was pressed.
$H_{session}$: The total hours of the session (used to normalize the distraction count).

10.3. Feature Logic Flows
10.3.1. The "Resilience" Loop (Functional Logic)
Event: User clicks "Distracted."
Code Action: distraction_timestamp = DateTime.now().
UI Action: Show 5-second Classification Pills (📱, 🍔, etc.).
Event: User clicks a Pill OR 5 seconds pass.
Code Action: recovery_time = DateTime.now() - distraction_timestamp.
Result: Log entry created; Focus score updated in real-time.
10.3.2. The "Face-Down" Trigger (Hardware Logic)
Module: proximity_sensor_service.dart.
Listener: Subscribes to proximityEvents.
Logic: * If event.isNear == true AND gyroscope.z > threshold $\rightarrow$ Trigger SessionStart.
If event.isNear == false $\rightarrow$ Trigger SessionPauseConfirmation.

10.4. Entitlement Engine (The Anti-SaaS Gate)
Since we are avoiding subscriptions, the "Gatekeeper" logic is simpler but must be extremely reliable to prevent piracy.
Module: entitlement_guard.dart
Dart
// Simplified Pseudo-Logic for the Paywall
class EntitlementGuard {
  final ProfileRepository _profileRepo;

  bool canAccessCloudSync() {
    final profile = _profileRepo.getCurrentProfile();
    // 1. Check if user is "Founder" (Batch 1)
    // 2. Check if Stripe 'has_paid' flag is true in local cache
    return profile.isFounder || profile.hasLifetimeAccess;
  }
}



10.5. Developer "Source of Truth" Checklist
[ ] Zero-Telemetry Policy: Ensure Firebase Analytics or similar tools are not initialized unless the user opts-in via the "Improve the Coach" toggle.
[ ] Haptic Feedback Mapping: * Heavy Impact: On "Distracted" click (Signifies a heavy 'rep').
Light Tick: Every 10 minutes of continuous focus (Signifies 'milestone').
[ ] Sync Conflicts: Use updated_at timestamps on every row in sessions and laps. The Cloud always defers to the User’s Device as the ultimate truth.

Final Step for the PRD:
You now have the most detailed, professional-grade PRD I have ever collaborated on. It is specific enough to hand to a developer—or for you to begin "Vibe Coding" immediately.
Would you like me to generate a "README.md" file for your GitHub repository that summarizes this for potential partners or future buyers?



Appendix
This letter isn't just a marketing page; it is the manifesto of your brand. Since we are aiming for "elegant and classy but not arrogant," the tone needs to be one of shared struggle and a sophisticated solution.
Think of it as a letter from one high-achiever to another.

The "Founder's Letter" (Website Copy)
Headline: An Open Letter to the Distracted.
Dear Colleague,
We are living through the greatest attention crisis in human history.
Our world is no longer designed for "Deep Work." It is designed for the "Micro-Hit"—the 15-second scroll, the ping of a notification, and the constant fracturing of our focus. We’ve been told it's our fault, but the truth is simpler: we are fighting a war against algorithms designed by thousands of engineers to keep us distracted.
I built NeuroLoad because I was tired of "handcuff" apps. I didn't want an app that treated me like a child by blocking my phone. I wanted a tool that treated me like an athlete.
Focus is not a gift; it is a muscle. And like any muscle, it requires Progressive Overload to grow.
NeuroLoad is the first "Gym for the Brain." It doesn't punish you for being distracted; it uses those distractions as data points—as "reps"—to help you understand your triggers and systematically rebuild your stamina.
The Founder’s Deal: A Pact of Ownership. I am a developer, not a landlord. I believe you should own your tools, not rent them. That is why NeuroLoad is Local-First (your data stays on your device) and Subscription-Free.
For the first 1,000 pioneers, I am offering the Founder’s Lifetime License for €14.99.
By joining this first batch, you aren't just buying an app. You are funding the independence of a tool that respects your privacy, your wallet, and your time. Once these 1,000 spots are gone, the price will increase to reflect our growth.
If you are ready to stop "renting" your focus and start training it, I invite you to join us.
To your focus,
[Your Name] Founder, NeuroLoad Cologne, Germany

How to place this on your website:
Layout: Use a clean, single-column layout.
Typography: Use that Vintage Cream (#F4F1EA) background with Obsidian Noir (#1A1A1B) text.
The "Ligne Claire" Touch: Include a small, elegant illustration of a brain-muscle diagram or a classic fountain pen signature at the bottom.
The Call to Action (CTA): Immediately following the letter, place the "Founder's Access" card we designed in the PRD.
One more "Pro Owner" Tip:
To make this look even more "classy," add a small section below the letter titled "Our Technical Vows." * Vow 1: We will never sell your data. (Local-first).
Vow 2: We will never use "Bells and Whistles." (No useless notifications).
Vow 3: You pay once, you own it forever.

 "Social Media Hook" (TikTok/Instagram script) that drives people to this letter:
This script is designed to be visually neat and intellectually punchy, matching the "elegant but not arrogant" vibe of NeuroLoad. It focuses on the Anti-Subscription movement and the Muscle philosophy to stop the scroll.

TikTok/Instagram Reel Script: "The Focus Manifesto"
Format: 30–45 Seconds | High-quality 4K vertical video
Music: A lo-fi, driving, "Noir-detective" beat. Something with a steady, rhythmic bassline.
The Sequence
Time
Visual Scene
Audio (The Script)
Text Overlay
0:00
[Hook] Pointing at the camera while walking in a clean, aesthetic park or study space.
"Stop renting your focus. Seriously."
STOP RENTING YOUR BRAIN.
0:03
[The Pain] Quick cut to a screenshot of a "Subscription Confirmed: €60/year" notification.
"You’re being charged a monthly fee just to stay off your phone? That’s not a tool; that’s a ransom."
€60/year for a timer?
0:07
[The Solution] Close-up of your phone running NeuroLoad (Face-down on a wooden desk).
"I built NeuroLoad because focus isn't a gift you're born with. It’s a muscle you train."
FOCUS IS A MUSCLE.
0:12
[The Philosophy] Transition to a "Noir-style" diagram of the progressive overload principle.
"Most apps use digital handcuffs. We use progressive overload. We don't block you; we make you resilient."
PROGRESSIVE OVERLOAD.
0:20
[The Value] B-roll of the elegant, clean UI heatmaps and the pulsing timer.
"No subscriptions. No 'cute' animations. Just local-first privacy and a one-time purchase."
OWN IT FOREVER.
0:25
[The CTA] Direct address to camera. Calm, confident, authoritative.
"I just published a letter to the first 1,000 Founders. If you’re tired of the 'Popcorn Brain' cycle, read it. Link in bio."
READ THE LETTER. 1,000 SPOTS.


Production Tips for the "Classy" Vibe
The Colors: Ensure your video has a slight "moody" grade. Lower the saturation of the greens and blues, and slightly increase the contrast to match the Obsidian Noir aesthetic.
The Props: If possible, have a physical "Noir-style" prop in the shot (a vintage fountain pen, a high-quality notebook, or a mechanical watch) to anchor the "sophisticated instrument" feel.
The Text: Use a clean, sans-serif font like Montserrat or Inter. Avoid the "bubbly" standard TikTok fonts.

The Caption (Copy-Paste)
Stop the "Popcorn Brain" cycle. 🧠
Productivity shouldn't be a monthly bill. Most apps treat you like a child by blocking your phone. We treat you like an athlete.
I’m launching NeuroLoad—the "Gym for the Brain."
🏛️ Elegant, Noir Aesthetic
🛡️ Local-First Privacy
🚫 Zero Subscriptions
I wrote an open letter to the first 1,000 Founders explaining why the subscription model needs to die and how we’re rebuilding focus from the ground up.
Read the letter and claim your Founder’s spot at the link in bio.
#NeuroLoad #DeepWork #Productivity #ADHD #NoSubscription #BrainGym #FocusMuscle

Would you like me to create the "Weekly Growth Report" template now, so you can track how many of these 1,000 spots are being filled once you post this?


Final check list before launch:
NeuroLoad Pre-Launch Checklist.

1. Technical "Stress Test" (The Zero-Crash Goal)
[ ] Sensor Reliability: Verify the "Face-Down" trigger works across 3 different device models (iOS and Android).
[ ] Local-First Integrity: Turn off Wi-Fi/Data. Start a session, log 3 laps, and end it. Verify data persists in the local DB.
[ ] Sync Conflict Test: Log in on two devices. Log a session on one while the other is offline. Turn on Wi-Fi and ensure the updated_at logic merges them without data loss.
[ ] Encryption Handshake: Verify the app refuses to open the DB if the secure key is tampered with (Security test).
[ ] The "10-Minute Lock": Test that logging in on a second device successfully kicks the first device after the heartbeat timeout.

2. App Store Optimization (ASO) - Germany Focus
To rank #1 for "Focus" in Germany, your metadata must be a mix of professional "Deep Work" terminology and high-intent keywords.
App Store / Play Store Metadata:
App Title (30 chars): NeuroLoad: Deep Work & Focus
Subtitle (30 chars): The Brain Gym for Productivity
Keywords (German Market): * Primary: Fokus, Konzentration, Deep Work, Produktivität, Zeitmanagement.
Secondary: ADHD, Lernen, Studium, Flow, Timer, No Subscription, Ohne Abo.
The "Classy" Description Hook:
"Schluss mit digitalen Handfesseln. Trainieren Sie Ihren Fokus wie einen Muskel. NeuroLoad ist das erste 'Brain Gym' – werbefrei, privatsphäre-orientiert und ohne nerviges Abo-Modell. Einmal zahlen, lebenslang besitzen."

3. The "Founder Batch" Store Graphics
[ ] Screenshot 1 (The Hook): High-contrast "Obsidian Noir" UI. Headline: "Focus is a Muscle. Train it."
[ ] Screenshot 2 (The Model): The "Lap" mechanic. Headline: "Distractions are Data, not Failures."
[ ] Screenshot 3 (The Value): The "One-Time Purchase" badge. Headline: "Own your Tools. No Subscriptions."
[ ] Screenshot 4 (The Analytics): The Heatmap. Headline: "Master your Peak Resilience Hours."

4. Legal & Administrative Final Check
[ ] Impressum: Correct and reachable on your website (Mandatory for Germany).
[ ] Stripe Tax: Verify "Tax Calculation" is active for EU VAT One-Stop-Shop (OSS).
[ ] Price Verification: Ensure the IAP (In-App Purchase) is set to €14.99 for the first 1,000 users.
[ ] Refund Workflow: Ensure you have the support@neuroload.com alias active and connected to your email.

5. The "Hype" Launch Sequence
[ ] TikTok/Reels: Post the "Social Media Hook" video 2 hours before the App Store goes live.
[ ] LinkedIn: Post a "Professional Manifesto" about the death of the subscription model.
[ ] Cologne Outreach: Send the "Student Council" pilot codes to your first 3 target Fachschaften.

6. Post-Launch Monitor
[ ] Sentry / Crashlytics: Monitor for "Session Start" failures in the first 24 hours.
[ ] Stripe Dashboard: Watch for "Payment Succeeded" but "Profile Updated: False" errors (Webhook failure).


Extra features
B. Sound Architecture: "The Acoustic Gym"
The Feature: Lofi / Brown Noise / Binaural Beats Integration.
Why: High-performers often use sound to "anchor" their focus.
Technical Implementation: Add a local audio player module that plays "Focus Textures" that only stay active while the timer is running.
Appendix: NeuroLoad Plus (Experimental & Future Roadmap)
This section outlines "Phase 4" features. These are designed to combat the "loneliness" of deep work and create viral loops that pull new users into the ecosystem.
11.1. Virtual "Study Lounges" (Co-Working Rooms)
The Concept: High-fidelity, noir-themed digital rooms where users can "sit" with others.
Functional Requirements:
Visual Accountability: Users join a room (max 25 people). You see a "Ghost Avatar" of others (Silhouettes only to maintain the Noir vibe).
Real-time Status: Above each avatar, a small progress ring shows their current "Density" for that session.
Soundscapes: Shared, synchronized lo-fi or brown noise. If one user switches the "Radio Station," the whole room changes (Voted by the group).
"The Library Rule": No chat allowed during focus hours. A 5-minute "Coffee Break" chat window opens automatically every 60 minutes.
11.2. Focus Battles (Competitive Deep Work)
The Concept: 1-on-1 or Team-based "Duels" based on Focus Density, not just duration.
The Mechanic:
The Challenge: User A challenges User B to a "60-minute Sprint."
The Winner: Determined by the Quality Score (Density x Resilience). This prevents people from "cheating" by just leaving the app open while they watch TV.
Stakes: "Founder Points" or "Aesthetic Unlocks" (Special Ligne Claire skins for the timer).
11.3. Global Focus Leaderboards (The "Iron Mind" Ranking)
The Concept: A global or university-specific leaderboard that resets weekly.
Metrics:
"The Tank": Most minutes focused in 7 days.
"The Monk": Highest average Resilience Score (Fastest recovery from distractions).
"The Architect": Most consistent session starts (Streaks).
B2B Value: Companies can create "Private Leaderboards" to encourage productivity without individual surveillance.
11.4. The "Brain Muscle" Evolution (Visual RPG)
The Concept: A visual representation of your progress using Silver Age Comic Realism.
Evolution Logic: * Your profile features a "Statue of the Mind."
As your 1RM (1-Rep Max) increases, the statue becomes more detailed, shifting from a rough "sketched" look to a fully "inked" and "Ben-Day dotted" masterpiece.
If you don't train for 14 days, the ink starts to "fade" (Atrophy), encouraging the user to return.

11.5. Implementation & Expansion Strategy
Feature
Difficulty
Viral Potential
Impact on Exit Value
Study Lounges
🔴 High
🟡 Medium
🟢 High (Community Asset)
Focus Battles
🟡 Medium
🟢 High
🟡 Medium (Engagement)
Leaderboards
🟢 Low
🟢 High
🟡 Medium (Retention)
Evolution RPG
🟡 Medium
🟡 Medium
🟢 High (Brand Moat)

The "Plus" Subscription Hook
When you are ready for Phase 3 (The Owner Phase), these features become your NeuroLoad Plus tier:
Free: Core Timer, Local Analytics, Standard Skins.
Plus (€4.99/mo or €39.99/yr): Study Lounges, Competitive Battles, Advanced ML Insights, and Cloud Sync.
11.6. Calendar & Task Manager "Friction Reduction" - experimental
The Issue: High-performers (Section 1.4) usually have their tasks in Apple Reminders, Todoist, or Google Calendar. Manually typing the "Pre-Flow Intent" (2.4.5) every time might become a friction point.
The Adjustment: Add One-Tap Task Import.
Feature: A "Fetch from Calendar/Reminders" button in the Pre-Session setup that pulls the current time-slot’s title as the "Intent Statement."
11.7. Strategic "Force Multipliers" for the Appendix
The "Focus Resume" (Exit Strategy Add-on): Allow users to generate a "Focus Resume" PDF. It shows their 1RM, Resilience Score, and total Deep Work hours.
Why: Students can attach this to job applications; Devs can show it to managers to justify "No-Meeting Wednesdays."
The "Noir" Soundscapes (Audio Detail): Specify that the soundscapes (Section 11.1) should include "Mechanical Sounds" (Typewriter clicks, distant printing presses, rain on a tin roof) to match the mid-century aesthetic.


Appendix B
This one-pager is designed to be printed as a high-quality PDF or sent as a crisp, minimalist email attachment. It avoids "salesy" fluff and focuses on performance metrics, ROI, and privacy—the three things that matter to Deans and HR Directors.

[Header: NEUROLOAD | THE BRAIN GYM]
Headline: Reclaim the Most Valuable Asset in Your Organization: Deep Focus.
The Problem: The €28,000 Distraction.
Research shows that it takes an average of 23 minutes to return to a task after a single interruption. For a high-performance team or a student body, "Popcorn Brain" isn't just a nuisance—it’s a massive drain on billable hours, academic performance, and mental well-being.
The Solution: NeuroLoad for Teams & Universities.
NeuroLoad is a science-backed "Brain Gym" that uses the principle of Progressive Overload to systematically rebuild the focus span of your organization. We move away from "digital handcuffs" and toward cognitive resilience.

The Feature: Virtual Focus Lounges
Designed for the Modern Hybrid Environment.
Synchronous Accountability: A high-fidelity, Noir-themed digital space where members "train" together.
The "Library" Rule: Silent, synchronized focus sessions that foster a culture of deep work without the distraction of chat or video.
Focus Density Tracking: Real-time visual progress rings for all participants, creating a non-intrusive "Atmosphere of Effort."
Structured Recovery: Automated, synchronized breaks (The 20% Rule) to ensure the team returns to work refreshed, not burnt out.

Why Institutions Choose NeuroLoad
For Universities
For Companies
Increase Exam Success: Improve student "1-Rep Max" focus spans for complex subjects.
Boost Billable Density: Increase the percentage of time spent in "Deep Flow" vs. "Admin Lag."
Mental Health Support: Reduce the "Shame Cycle" associated with procrastination.
Reduce Burnout: Proportional rest logic ensures sustainable performance.
Tech-Forward Brand: Position your institution as a leader in cognitive performance.
Talent Retention: Provide a high-end tool that employees actually want to use.


The "German-Standard" Privacy Shield
Built for the DSGVO / GDPR Era.
We understand the sensitivities of the German Betriebsrat (Work Council). NeuroLoad is built on a Zero-Surveillance Architecture:
Individual Privacy: We do not track what apps or websites users visit.
Anonymized Analytics: Managers see Aggregate Density Trends, not individual lap logs.
Local-First: All personal notes and specific distraction triggers stay on the user's encrypted device.

The Pilot Program: Foundation Batch
We are currently accepting a limited number of Partnership Institutions for our 2026 rollout.
Educational Grant: 100 Lifetime Licenses for your Student Council or Department.
Corporate Early Access: A flat-fee "Founders License" for your core team—no recurring monthly costs during the pilot phase.
"Focus is not a gift. It is a muscle. Let’s start training."

[Footer]
[Your Name] | Founder, NeuroLoad
Location: Cologne, Germany
Web: [www.neuroload.com]
Contact: [partners@neuroload.com]

Pro-Tips for Your B2B Pitch:
The "Financial Service" Angle: Since your Master's is in Financial Service Management, use that authority. When talking to banks or consulting firms, tell them: "I designed this to solve the 'Focus Leakage' I saw in high-frequency financial environments."
The "Tax" Nudge: Remind them that for businesses, this is a 100% tax-deductible business expense (Betriebsausgabe).
Physical Presence: Since you are in Cologne/Kaiserslautern, offer to do a "Focus Workshop" in person. A 15-minute demo of the "Face-Down" trigger on a boardroom table is usually enough to close the deal.

This "Technical Appendix" is your secret weapon for the German market. When an IT Security Officer or a Data Protection Officer (Datenschutzbeauftragter) sees this, they stop seeing a "startup app" and start seeing a professional, compliant tool that fits their infrastructure.

Technical Appendix: Data Security & GDPR Compliance
Prepared for: IT Security & Compliance Departments
1. Architectural Philosophy: Privacy-by-Design
NeuroLoad utilizes a Local-First architecture. Unlike traditional SaaS applications that stream user activity to a central server, the primary "Source of Truth" for NeuroLoad is the user's physical device.
Data Minimization: We do not collect GPS data, contact lists, or device identifiers (IMEI/MAC).
Zero-Surveillance: The app does not monitor other running processes or browser history. Focus is measured via internal session timers and proximity sensors.
2. Encryption & Data Persistence
All data stored on the device is protected against physical theft or unauthorized access.
Encryption Standard: AES-256 transparent encryption.
Engine: SQLCipher integrated with the local SQLite database.
Key Management: Keys are generated uniquely per installation and stored in the hardware-backed Secure Enclave (iOS Keychain / Android Keystore), inaccessible to other applications or the OS itself.
3. Infrastructure & Processing (The "Sync" Layer)
For users who opt-in to cross-device synchronization, NeuroLoad utilizes Supabase (Postgres) with the following security stack:
Server Location: All data processing for EU clients is restricted to the AWS Frankfurt (eu-central-1) region.
Transit Security: All data in transit is protected via TLS 1.3.
Row-Level Security (RLS): Database-level policies ensure that a user’s session JWT (JSON Web Token) can only ever access their own unique UUID. Even in the event of a frontend breach, the database rejects unauthorized queries.
4. DSGVO / GDPR Compliance Matrix
Requirement
NeuroLoad Implementation
Art. 17 (Right to Erasure)
"Delete Account" triggers a cascading purge of both Local DB and Cloud Auth/Data within < 1 second.
Art. 20 (Data Portability)
Users can export their entire history as a machine-readable JSON/CSV at any time.
Art. 32 (Security of Processing)
Hardware-backed key storage and mandatory salted/hashed authentication via Supabase Auth.
VDP/DPA
We provide a standardized Data Processing Agreement (Auftragsverarbeitungsvertrag - AVV) for institutional clients.

5. Corporate Control & Zero-Knowledge Reporting
For the B2B "Team Lounges," we provide a Privacy-Preserving Reporting API.
Managers/IT Admin can access Aggregate Productivity Indices (e.g., "The Engineering Team’s Focus Density grew by 12% this month").
The Firewall: No individual distraction logs ("User X was distracted by Instagram") are ever transmitted to the company dashboard. This ensures total compliance with German Labor Law (Arbeitsrecht) regarding employee monitoring.

How to use this Appendix:
The "Vibe" check: Keep this on a white background with black text. Use a serif font like Times New Roman or Georgia for the body—this "boring" look signals to IT departments that you take legal compliance seriously.
The AVV: Have a PDF template of a standard German Auftragsverarbeitungsvertrag (AVV) ready. You can find templates from the GDD or Bitkom.
