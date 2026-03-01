# NeuroLoad - Comprehensive User Stories

Based on the Product Requirements Document (PRD), here is the expanded list of user stories required to build the product.

## Epic 1: The "Gym" (Focus Session Management)

### US 1.1: Context Setup (Pillars)
*As a user, I want to select a primary category (Study, Work, Creative, Admin, Lifestyle) before starting so my focus time has a contextual baseline.*
**Acceptance Criteria:**
- User must select exactly one of the 5 categories before the "Start" button becomes active.
- Selected category state is passed to the session object.
**Tasks:**
- [ ] Create UI component for the 5 primary category selector (Radio/Pill buttons).
- [ ] Implement state management (Riverpod) to hold the selected `PrimaryCategory`.

### US 1.2: Dynamic Sub-Category
*As a user, I want to input a sub-category (max 30 chars) with auto-suggestions of my top 5 used in that category to quickly define my specific task.*
**Acceptance Criteria:**
- Text input is limited to 30 characters.
- Tapping the input shows up to 5 historical sub-categories mapped to the chosen primary category.
**Tasks:**
- [ ] Create text input field with 30-character validation.
- [ ] Write local SQLite query to fetch top 5 sub-categories for the selected primary category.
- [ ] Implement auto-suggest dropdown/chips below the input.

### US 1.3: The "Baseline Aim"
*As a user, I want a toggle-based selector to set a target for my 1-Rep Max (1RM) for this session, showing my last 3 PBs to nudge me toward a 5% increase.*
**Acceptance Criteria:**
- Shows the current 1RM for the selected category.
- Provides a quick toggle to select a target duration (+5% of current 1RM).
**Tasks:**
- [ ] Create target duration UI selector.
- [ ] Fetch historical 1RM data from SQLite for the specific category.
- [ ] Calculate the +5% nudge value and display it dynamically.

### US 1.4: Pre-Flow Intent Statement
*As a user, I want to write a single-sentence intent before the timer starts, acting as a micro-contract that can be shown to me if I get distracted.*
**Acceptance Criteria:**
- Text field captures the intent (max 100 characters).
- This string is saved into the active session state.
**Tasks:**
- [ ] Add Intent text input to the pre-session setup screen.
- [ ] Store intent string in the session object and pass it to the timer screen.

### US 1.5: Manual Start Mode
*As a user, I want to start a session by clicking a primary "Start Session" button.*
**Acceptance Criteria:**
- Button is disabled until a Primary Category is chosen.
- Clicking transitions the app to the Main Timer screen and records `start_time`.
**Tasks:**
- [ ] Implement "Start Session" button with validation logic.
- [ ] Trigger navigation to Timer screen and initialize the `Session` DB record.

### US 1.6: Frictionless Start Mode
*As a user, I want to start a session automatically by flipping my phone face-down (using proximity/gyro sensors).*
**Acceptance Criteria:**
- If on the setup screen and all mandatory fields are filled, placing the phone face-down triggers the session start automatically.
- A haptic "Double-Success Tap" confirms the session started.
**Tasks:**
- [ ] Implement `sensors_plus` and `proximity_sensor` listeners on the setup screen.
- [ ] Implement logic: if proximity == near && gyro.z > threshold => Start Session.
- [ ] Trigger the double-success haptic pattern.

### US 1.7: The "Breathing" Ring
*As a user, I want the central timer UI to be a Ligne Claire circle pulsing at 6 cycles per minute to guide meditative breathing.*
**Acceptance Criteria:**
- The ring continuously pulses (opacity 100% -> 85% -> 100%) exactly every 10 seconds.
- The ring uses the Silver Age Gray color.
**Tasks:**
- [ ] Create custom Flutter widget for the Breathing Ring.
- [ ] Implement specialized `AnimationController` for a 10-second loop.

### US 1.8: Ambient Display Logic
*As a user, I want to double-tap the center of the screen to hide the digital clock (mm:ss) and only see the pulsing ring to reduce time-anxiety.*
**Acceptance Criteria:**
- Double-tap on the timer toggles the visibility of the digital time text.
- The pulsing ring continues regardless of text visibility.
**Tasks:**
- [ ] Wrap the timer text in an `AnimatedOpacity` widget.
- [ ] Add `GestureDetector.onDoubleTap` to toggle the boolean state.

### US 1.9: Haptic Milestones
*As a user, I want to feel a subtle, high-frequency haptic tick every 10 minutes to subconsciously signal progress without an audible alert.*
**Acceptance Criteria:**
- Every exactly 600 seconds, the device triggers a light haptic pulse.
- No sound is played.
**Tasks:**
- [ ] Create a background timer/ticker that tracks modulo 600 seconds.
- [ ] Call `HapticFeedback.lightImpact()` on the tick.

### US 1.10: The "Lap" Trigger Button
*As a user, I want a large (min 88px) "Distracted" button that I can tap to feel a heavy "Thud" haptic and log a distraction without stopping the main timer.*
**Acceptance Criteria:**
- The button is fixed at the bottom, minimum 88dp height.
- Tapping it triggers a heavy haptic response immediately.
- The main timer does NOT pause or stop.
**Tasks:**
- [ ] Build the oversized "Distracted" Action Button.
- [ ] Bind tap event to `HapticFeedback.heavyImpact()`.
- [ ] Append a new `Lap` object to the current session's state (recording absolute time).

### US 1.11: Distraction Classification Modal
*As a user, I want a modal with 6 icons to appear immediately after I hit the "Distracted" button so I can quickly categorize the interruption.*
**Acceptance Criteria:**
- A bottom modal sheet instantly appears over the timer.
- It displays 6 predefined trigger categories (e.g., Phone, Need, Noise).
**Tasks:**
- [ ] Implement `showModalBottomSheet` triggered by the Lap button.
- [ ] Create the 6-icon grid layout (2 cols x 3 rows).

### US 1.12: 5-Second Auto-Dismiss
*As a user, I want the classification modal to auto-close after 5 seconds (shown by a fading progress bar) and tag the lap as "Involuntary" if I don't select anything, preserving my flow.*
**Acceptance Criteria:**
- Modal contains a countdown progress bar shrinking over 5000ms.
- If no interaction happens, modal closes automatically and sets the Lap trigger to "Involuntary".
**Tasks:**
- [ ] Implement a `Timer` inside the modal initialized to 5 seconds.
- [ ] Animate a linear progress bar matching the timer.
- [ ] Auto-pop the route and save the default value on timeout.

### US 1.13: Lap Text Field
*As a user, I want an optional text field restricted to 4 words when I select a classification icon to add quick context to my distraction.*
**Acceptance Criteria:**
- Selecting an icon expands a text field.
- Validation prevents entering more than 4 words.
**Tasks:**
- [ ] Show text input upon icon tile selection.
- [ ] Add regex/split validation to enforce the 4-word maximum rule.
- [ ] Save the note string to the `Lap` object upon submission.

### US 1.14: Session Termination
*As a user, I want to end my session by flipping my phone face-up and holding a "Finish" button for 2 seconds to prevent accidental stops.*
**Acceptance Criteria:**
- Stop button requires a "Long Press" (2000ms) to activate.
- Progress ring fills up around the button while holding.
**Tasks:**
- [ ] Build a custom Long Press button wrapper.
- [ ] Implement the visual feedback ring during the 2-second hold.
- [ ] Trigger session finalize logic (calculate Quality Score, save end_time).

### US 1.15: The "Zombie Session" Guardrail
*As a user, I want the system to detect if I've left the app running for 120 minutes with no activity and automatically cap the session to ensure data integrity.*
**Acceptance Criteria:**
- If 120 minutes pass without a Lap, motion, or heartbeat, the active session is parked.
- The timer stops recording active focus density.
**Tasks:**
- [ ] Implement background activity monitoring (last interaction timestamp).
- [ ] Create a daemon/service to automatically suspend the session if `current_time - last_interaction > 120m`.

### US 1.16: Recovery Modal
*As a user, upon opening the app after a "Zombie Session", I want to be prompted to manually confirm the actual end time of my previous session so my KPIs aren't skewed.*
**Acceptance Criteria:**
- App checks for "Parked" zombie sessions on launch.
- A modal forces the user to drag a slider or input the actual time they stopped focusing before they can start a new session.
**Tasks:**
- [ ] Add app-launch check for unfinalized zombie sessions.
- [ ] Build the Time-Correction UI modal.
- [ ] Update the session's `end_time` based on user input and commit to DB.

### US 1.17: Post-Session Analysis Report
*As a user, I want a post-session summary displaying my session 1RM, total laps, Quality Score, and the primary "Focus Killer" identified.*
**Acceptance Criteria:**
- After finalizing, route to a Summary Screen.
- UI displays the calculated Quality Score, longest lap (1RM of session), and most frequent distraction category.
**Tasks:**
- [ ] Build the Quality Score Card UI.
- [ ] Write the aggregation logic to find the longest lap and highest frequency trigger.
- [ ] Render the "Vintage Seal" design for the score.

## Epic 2: The "Rest" (Recovery System)

### US 2.1: Dynamic Break Earning
*As a user, I want my break time to be dynamically calculated based on my average lap length (max 30 mins) so I earn proportional recovery.*
**Acceptance Criteria:**
- Break Time = (Sum of Lap Lengths / Total Laps) * 0.20.
- Result is capped at 30 minutes. If session < 10 mins, break = 0.
**Tasks:**
- [ ] Implement the break duration math formula.
- [ ] Apply min/max boundary constraints.

### US 2.2: Break UI Visual Shift
*As a user, I want the UI colors to transition from Obsidian Noir to Mid-Century Teal/Sage during a break to clearly indicate downtime.*
**Acceptance Criteria:**
- The background and accent colors animate to the Rest palette.
**Tasks:**
- [ ] Define Rest Mode Theme variables.
- [ ] Animate theme transition upon entering Rest state.

### US 2.3: Break Notifications
*As a user, I want a low-frequency soft wake chime at T-minus 60 seconds and a single elegant chime when the break is over so I don't miss my return to focus.*
**Acceptance Criteria:**
- At 60s remaining, device plays "Soft Wake" audio via local notification.
- At 0s, "Ready to Train" chime plays.
**Tasks:**
- [ ] Integrate local notifications package.
- [ ] Schedule exact-time notifications for T-60 and T-0 marks using custom sound files.

### US 2.4: The "One More Rep" Nudge
*As a user, I want the app to prompt me to keep going if I attempt to end a session just a few minutes shy of my Personal Best 1RM.*
**Acceptance Criteria:**
- If user holds the "Finish" button but current active lap is within 10% of their historical 1RM, an alert dialog interrupts the finish sequence.
- Shows "You are X mins away from your PB. Keep going?"
**Tasks:**
- [ ] Add pre-finish check logic comparing current lap time to historical 1RM.
- [ ] Build the Alert Dialog with "Keep Going" vs "End Anyway" actions.

## Epic 3: The "Dashboard" (Progressive Overload Analytics)

### US 3.1: Daily/Weekly/Monthly Heatmaps
*As a user, I want to view a 24-hour circular heatmap showing my most dense focus times so I know when I am most productive.*
**Acceptance Criteria:**
- Dashboard renders a 24-hour circular chart.
- Color intensity correlates directly to the number of active focus minutes in that hour block.
- Toggle between Daily, Weekly, and Monthly aggregations.
**Tasks:**
- [ ] Implement query to aggregate focus minutes by hour of day.
- [ ] Build custom 24-hour circular heatmap widget using `CustomPainter`.
- [ ] Add Day/Week/Month toggle state logic.

### US 3.2: Distraction Density Map
*As a user, I want to see a map identifying my "Danger Zones" (e.g., highly distracted hours) so I can prepare accordingly.*
**Acceptance Criteria:**
- A secondary heatmap view shows count of Laps (distractions) by hour.
- Highlights hours where ratio of Laps to Focus Time is unusually high.
**Tasks:**
- [ ] Implement query to aggregate Lap entries by hour of day.
- [ ] Overlay Lap Density data on the circular heatmap or create a separate comparative view.
- [ ] Style the "Danger Zones" with warning accent colors.

### US 3.3: Focus Density Tracking
*As a user, I want to see my Focus Density KPI (percentage of session spent in active flow minus recovery) to understand session quality.*
**Acceptance Criteria:**
- Focus Density is calculated as: `(Total Session Time - (Total Laps * Avg Resilience Time)) / Total Session Time * 100`.
- Displayed as a large percentage metric on the dashboard.
**Tasks:**
- [ ] Write SQL view/query to calculate historical Focus Density averages.
- [ ] Create KPI metric Card widget.
- [ ] Show trend indicator (up/down arrow) compared to previous week.

### US 3.4: Resilience KPI Tracking
*As a user, I want to track my average Resilience (time taken to close the classification modal and return to focus) so I can improve my recovery speed.*
**Acceptance Criteria:**
- System calculates the delta between Lap button press and Modal dismiss.
- Displays weekly average Resilience time in seconds.
**Tasks:**
- [ ] Ensure Lap time and Modal dismiss time are accurately recorded in DB.
- [ ] Create query to average these deltas.
- [ ] Build UI card for Resilience KPI.

### US 3.5: Distraction Trigger Pie Charts
*As a user, I want to see a pie chart breakdown of my distractions (Internal vs. External) to uncover my weaknesses.*
**Acceptance Criteria:**
- Top-level pie chart groups the 6 trigger categories into Internal vs. External.
- Tapping a slice drills down into specific categories (e.g., Phone, Noise).
**Tasks:**
- [ ] Define the Inner/Outer mapping of the 6 core triggers.
- [ ] Integrate highly-styled charting library (e.g., fl_chart) for the Pie Chart.
- [ ] Add drill-down animation state.

### US 3.6: Category-Specific Triggers
*As a user, I want to filter my distraction pie charts by primary category to see what specifically interrupts me during "Study" vs "Work".*
**Acceptance Criteria:**
- Dashboard contains a dropdown or tab bar to filter all analytics by Primary Category.
- Pie chart dynamically updates when a category is selected.
**Tasks:**
- [ ] Update all analytics queries to accept an optional `category_id` parameter.
- [ ] Build the filter UI component.
- [ ] Wire filter state to the analytics data providers.

### US 3.7: 1-Rep Max (1RM) Tracking
*As a user, I want the app to track my longest single span of focus without a distraction lap as my "Gold Standard" metric.*
**Acceptance Criteria:**
- System identifies the longest duration between session start and first lap, or between laps, or last lap and session end.
- Dashboard prominently displays the All-Time 1RM and Current Week 1RM.
**Tasks:**
- [ ] Create a DB trigger or calculation function that processes newly saved sessions to find the max interval.
- [ ] Store the 'Max Interval' explicitly in the Session record.
- [ ] Query and display the absolute highest value.

### US 3.8: Trophy Room UI
*As a user, I want a dedicated view showing the date and category of my top 5 all-time 1RMs to celebrate achievements.*
**Acceptance Criteria:**
- A styled list view explicitly showing the exact duration, date, and sub-category context.
- Uses Premium "Vintage Plaque" styling.
**Tasks:**
- [ ] Create simple `SELECT ... ORDER BY max_interval DESC LIMIT 5` query.
- [ ] Build the Trophy Room screen UI.
- [ ] Apply elegant gradient/shadow styling to list items.

## Epic 4: Coach Logic (Statistical Analysis)

### US 4.1: The "Silent Week" Data Gathering
*As a user, I want the app to silently monitor me for the first 7 days (or minimum 10 sessions) without offering advice, so it can build a statistically significant "User Profile Matrix" (Baseline 1RM, avg lap length, peak hours).*
**Acceptance Criteria:**
- Coach features and nudges are entirely disabled until `total_sessions >= 10` and `days_since_first_session >= 7`.
- A progress indicator in the Dashboard shows "Gathering Baseline Data X/10".
**Tasks:**
- [ ] Create an `isBaselineEstablished()` check function.
- [ ] Wrap all passive Coach UI elements in a visibility state checking this boolean.
- [ ] Build the "Gathering Data" placeholder UI.

### US 4.2: The "Next Aim" Algorithm (+5%)
*As a user, I want the Coach Logic to precisely calculate and suggest a target that is 5% longer than my current 1RM *only* if I have reached or exceeded my baseline 1RM for 3 consecutive sessions, ensuring I only progress when ready.*
**Acceptance Criteria:**
- System tracks current 1RM.
- If last 3 sessions' 1RMs are >= Current All-Time 1RM, suggest `Current 1RM * 1.05` on next session setup.
**Tasks:**
- [ ] Write logic to analyze the last 3 sessions for a specific category.
- [ ] Implement the mathematical multiplier.
- [ ] Push the suggested target to the Session Setup UI.

### US 4.3: The "De-load" Trigger (Confidence Rebuilding)
*As a user, I want the app to detect if my Focus Density drops below 60% for 3 consecutive sessions and suggest a "De-load Week" (e.g., targeting 20% *less* than my 1RM) to help me rebuild my focus confidence without failing.*
**Acceptance Criteria:**
- If rolling 3-session average Focus Density is < 60%, trigger the De-load alert on the Home screen.
- The suggested "Baseline Aim" is automatically reduced to `Current 1RM * 0.8`.
**Tasks:**
- [ ] Add condition to the session evaluation logic to check Focus Density drops.
- [ ] Create the "De-load Warning" UI alert dialog.
- [ ] Adjust the suggested target variable downward.

### US 4.4: Contextual Leak Identification
*As a user, I want the analysis engine to cross-compare my categories and explicitly notify me of "Contextual Leaks" (e.g., "Your 1RM in 'Admin' is 45m, but only 12m in 'Study'") so I know where my focus is weakest.*
**Acceptance Criteria:**
- Dashboard Coach section displays a warning if the delta between the highest 1RM category and lowest 1RM category exceeds 50%.
**Tasks:**
- [ ] Create query to find max 1RM per category.
- [ ] Calculate the variance/delta between the categories.
- [ ] Generate the specific text string ("Your 1RM in X is Y...").

### US 4.5: Active Strategy Recommendations
*As a user with an identified Contextual Leak, I want the app to suggest specific mitigations (e.g., "Consider using the 5-minute 'Warm-up' mode for Study sessions") to actively fix the weakness.*
**Acceptance Criteria:**
- If a Contextual Leak is identified, pair it with a pre-written mitigation text based on the specific category or the primary distraction trigger involved.
**Tasks:**
- [ ] Build a local map/dictionary of static strategy recommendations mapped to Trigger types.
- [ ] Display the mapped string in the Coach UI below the leak identification warning.

### US 4.6: Circadian Rhythm Mapping
*As a user, I want the app to aggregate my historical Resilience Scores and Focus Density against the time of day to determine my "Biological Prime Time."*
**Acceptance Criteria:**
- Identify the 2-hour window where Focus Density is historically at its absolute highest.
- Set this window as a local variable: `prime_time_start` and `prime_time_end`.
**Tasks:**
- [ ] Write complex SQLite aggregation grouping average Density by hour.
- [ ] Find the 2-hour sliding window with the highest moving average.

### US 4.7: Empirical Scheduling Nudges
*As a user, I want the app to use my Biological Prime Time data to proactively suggest when I should schedule my hardest tasks (e.g., "You historically achieve highest resilience on Tuesday mornings. Do deep work then.") for a density boost.*
**Acceptance Criteria:**
- When a user selects a category associated with high difficulty, show a small text nudge if the current time is NOT in their Biological Prime Time.
**Tasks:**
- [ ] Create UI visibility logic dependent on current time vs `prime_time_window`.
- [ ] Render the nudge string dynamically.

### US 4.8: The "Ghost" Intent Reminder
*As a user who gets distracted, if I open the classification modal but fail to make a selection within 5s, I want the app to briefly flash my "Pre-Flow Intent Statement" on screen as a subconscious anchor to pull me back on task.*
**Acceptance Criteria:**
- Before the modal auto-dismisses at 5s, briefly showing the Intent text (e.g., for 1500ms centered on screen) before returning to the timer.
**Tasks:**
- [ ] Hook into the classification modal's timeout logic.
- [ ] Delay the actual UI pop by 1.5s, replace modal content with explicit Intent Text during that delay.

## Epic 5: Security & Absolute Privacy

### US 5.1: Local-First Data Storage
*As a user, I want ALL my focus logs and notes to be stored strictly on my local device's database by default (never in a central cloud), encrypted with AES-256 so my absolute privacy is guaranteed.*
**Acceptance Criteria:**
- App utilizes SQLCipher via Drift/sqflite for the local DB.
- Key is securely generated and stored in platform-specific hardware keystore (Keychain/Keystore).
**Tasks:**
- [ ] Integrate `flutter_secure_storage` to generate and persist the encryption key.
- [ ] Initialize Drift DB instance utilizing the SQLCipher bindings in the native layers.

### US 5.2: GDPR "Right to Erasure"
*As a user, I want a "Delete My Life" button that completely wipes my local app data and triggers a cloud cascade deletion if I have a synced account.*
**Acceptance Criteria:**
- Settings screen has a red "Wipe Data" button.
- Triggers a DROP/re-create of local SQLite tables.
- If logged in, sends an authenticated RPC call to Supabase to execute a user data wipe before logging out.
**Tasks:**
- [ ] Build the standard confirmation dialog (Are you sure? Type "DELETE").
- [ ] Write the local DB teardown function.
- [ ] Implement the Supabase `Edge Function` or RPC to handle the cloud cascade delete.

### US 5.3: Data Ownership (Export)
*As a user, I want to extract my entire focus history as a JSON/CSV file so I own my training data, not the app developers.*
**Acceptance Criteria:**
- "Export Data" button in Settings.
- Generates a zip wrapper containing `sessions.csv` and `laps.csv`.
- Triggers native Share sheet.
**Tasks:**
- [ ] Implement query to dump all local DB rows to standard objects.
- [ ] Construct the CSV strings programmatically.
- [ ] Utilize `share_plus` to present the generated file to the user.

### US 5.4: Opt-In Cloud Sync (Paid Only)
*As a paid user who explicitly opts-in, I want my logs to sync to a cloud database for multi-device access, but with identifying metadata scrubbed to maintain the "Shadow Log" privacy principle.*
**Acceptance Criteria:**
- Sync functionality requires authentication and an active premium license validation.
- Sync payload specifically excludes `device_name` or IP logs if possible, transmitting only raw Session/Lap timestamps and IDs.
**Tasks:**
- [ ] Create the Sync opt-in flow and check Stripe/License status.
- [ ] Build the Supabase table schema and strict RLS policies ensuring users only see their own `user_id` rows.

### US 5.5: "Strict Privacy" Toggle
*As a user testing cloud sync, I want an option to keep the notes attached to my Laps strictly local, preventing them from uploading to the cloud.*
**Acceptance Criteria:**
- A boolean toggle "Local-Only Notes" in Settings.
- If true, the sync payload sets the `note` field to `NULL` before transmitting to Supabase.
**Tasks:**
- [ ] Add `bool isLocalOnlyNotes` setting to local SharedPreferences.
- [ ] Modify the outgoing Sync mapping function to conditionally nullify notes based on this setting.

### US 5.6: The "Paid-Only" Cloud Bridge
*As a paid user, I want delta syncing of my sessions across my devices (Conflict Resolution: Last-Write-Wins) securely stored per RLS policies.*
**Acceptance Criteria:**
- App tracks `last_synced_at` globally.
- Only records modified or created *after* `last_synced_at` are uploaded.
- Supabase conflicts on matching IDs are resolved by taking the record with the newer `updated_at` timestamp.
**Tasks:**
- [ ] Add `updated_at` columns to all local tables and maintain them via DB triggers.
- [ ] Implement the REST/Supabase client delta pushing logic.
- [ ] Implement delta pulling logic to merge incoming cloud changes into local SQLite.

## Epic 6: Monetization, Licensing & B2B

### US 6.1: Dynamic Scarcity Pricing
*As a prospective buyer, I want to see the current pricing tier clearly based on the "Early Bird" lifetime model caps.*
**Acceptance Criteria:**
- App pulls current pricing tier from Stripe/Supabase Remote Config on Launch.
- Displays dynamic text (e.g., "Tier 1: 300 licenses remaining").
**Tasks:**
- [ ] Create Supabase table for `PricingTiers` and current limits.
- [ ] Build API fetch logic on checkout page initialization.
- [ ] Render the scarcity copy dynamically.

### US 6.2: The Forced Paywall
*As a free user who has completed exactly one session, I want to be confronted with a mandatory paywall the next time I open the app so I am forced to subscribe or buy a lifetime license to continue using it.*
**Acceptance Criteria:**
- On app launch, query local DB for count of completed sessions.
- If `session_count >= 1` and `license_status == free`, immediately push the Paywall full-screen modal blocking all other navigation.
**Tasks:**
- [ ] Add `checkPaywallStatus` block to app startup sequence.
- [ ] Build the blocking Paywall Screen widget with no "Close" button.
- [ ] Implement local caching of license status so it doesn't await network every launch.

### US 6.3: Stripe Checkout Flow
*As a user hitting the paywall, I want a secure checkout experience hosted by Stripe to purchase my license/subscription.*
**Acceptance Criteria:**
- Tapping "Purchase" generates a Stripe Checkout session URL and opens it in an in-app browser or native Custom Tab.
- Successful completion invokes a webhook that updates the user's `license_status` to premium.
**Tasks:**
- [ ] Integrate Supabase Edge function to handle Stripe Session creation.
- [ ] Implement `url_launcher` to open the Stripe URL.
- [ ] Build Stripe Webhook handler in Supabase to update the users table.

### US 6.4: Tax-Deductible Invoice
*As a professional/manager, I want to automatically receive an invoice via email outlining the VAT and proper description for tax deduction purposes.*
**Acceptance Criteria:**
- Post-purchase, an email is sent to the registered address.
- Email uses Resend API and contains a PDF link or formatted HTML with the company's tax ID and itemized VAT.
**Tasks:**
- [ ] Configure Stripe to auto-send receipts OR use Resend API triggered by the webhook.
- [ ] Define the Email text template with appropriate tax disclaimers.

### US 6.5: B2B Dashboard Purchase
*As a manager/educator, I want to access a web portal (Coach Dashboard) to purchase bulk "Seat Bundles" for my team or students.*
**Acceptance Criteria:**
- Next.js Web Portal allows buying 5, 10, or 50 seat bundles.
- Stripe processes bulk order and provisions 'X' amount of voucher codes to the manager's account.
**Tasks:**
- [ ] Build the Next.js `CoachDashboard` product selection UI.
- [ ] Ensure Stripe Checkout handles adjusting quantities.
- [ ] Write DB trigger to generate associated voucher codes upon successful payment.

### US 6.6: Voucher Claiming
*As an employee/student encountering the paywall, I want to enter an 8-character voucher code to instantly unlock access.*
**Acceptance Criteria:**
- An "I have a code" button on the Paywall opens a text input sheet.
- Entering a valid 8-character code marks the code as "claimed by User Y" and elevates the user's local status.
**Tasks:**
- [ ] Build Voucher Input UI with 8-character uppercase validation.
- [ ] Create Supabase RPC `claim_voucher(code)` handling the atomic lock and user elevation.

### US 6.7: "Gift of Focus" PDF
*As a buyer purchasing for someone else, I want a high-res digital certificate containing the access key generated to send as a gift.*
**Acceptance Criteria:**
- On completing a "Gift" purchase checkout, user receives a link to a dynamically generated PDF or styled HTML page indicating the voucher code.
**Tasks:**
- [ ] Create a styled Next.js dynamic route `/gift/[voucher_id]`.
- [ ] Render the "Vintage Seal" design for printing.

### US 6.8: B2B Seat Reclamation Protocol
*As a manager, I want to revoke a seat from a departed employee in the dashboard and reissue it to a new hire.*
**Acceptance Criteria:**
- Coach Dashboard lists all active claimed vouchers.
- Clicking "Revoke" nullifies the employee's user_id attached to that voucher and generates a new code string for the manager to share.
**Tasks:**
- [ ] Build the "Manage Seats" data table in Next.js.
- [ ] Implement Supabase RPC `revoke_and_reissue_voucher(voucher_id)`.

### US 6.9: B2B Privacy Shield View
*As a manager, I want to view my team's aggregate focus hours in the dashboard without seeing individual distraction logs or notes to respect privacy laws.*
**Acceptance Criteria:**
- The B2B Analytics view strictly aggregates `SUM(session_duration)` grouped by week/month for the whole organization.
- No individual employee IDs or names are exposed in the data payload.
**Tasks:**
- [ ] Write a highly restrictive SQL View in Supabase (`org_aggregate_stats`).
- [ ] Apply RLS so Managers can ONLY query this view, not the raw `sessions` table of their employees.

### US 6.10: Local Integrity on Revoke
*As an employee whose seat was revoked and is now facing the paywall again, I want my personal focus history and logs to remain on my local device.*
**Acceptance Criteria:**
- A revoked user loses cloud sync access and faces the paywall, but the SQLite data is untouched.
- If they purchase a personal license, they retain all historical data.
**Tasks:**
- [ ] Ensure the app's `checkPaywallStatus` logic does not trigger any local cascade deletes.
- [ ] Gracefully handle Supabase 401/403 errors during Sync attempts by pausing the sync engine queue.

## Epic 7: System Integrations & Hardware Polish

### US 7.1: The Lap Feed UI
*As a user, I want to see a vertical timeline below the timer indicating each distraction as a dot, which I can tap for details.*
**Acceptance Criteria:**
- Active Timer screen has a scrollable timeline UI beneath it.
- Dynamically updates as Laps are added.
- Tapping a node shows the selected Trigger Icon and optional note.
**Tasks:**
- [ ] Build `ListView.builder` for the timeline.
- [ ] Implement custom Timeline Node drawing (dots and connecting lines).
- [ ] Connect strictly to the local `Session.laps` state stream.

### US 7.2: Desktop "Digital Flip"
*As a desktop user, I want the ability to start the timer via a global hotkey or by placing my concurrently active mobile app face-down nearby.*
**Acceptance Criteria:**
- Web/Desktop app listens for a WebSocket/Realtime signal from Supabase triggered by the mobile app's face-down event.
**Tasks:**
- [ ] Implement Supabase Realtime broadcast channels `session_${user_id}`.
- [ ] Mobile app broadcasts "Session_Started" on Face-Down.
- [ ] Desktop app subscribes and triggers its local timer UI on receipt.

### US 7.3: Adaptive Sensor Polling
*As a mobile user, I want the app to stop polling proximity and gyroscope sensors aggressively after 5 minutes of stability to preserve my battery.*
**Acceptance Criteria:**
- If the device is face down and has not moved above a gyro threshold for 5 minutes, decrease sensor polling frequency from 60hz to 1hz.
**Tasks:**
- [ ] Write a custom wrapper around `sensors_plus` stream.
- [ ] Implement the timeout and throttle logic.

### US 7.4: Live Activities (iOS)
*As an iOS user, I want the timer to persist on my Lock Screen and Dynamic Island so the OS doesn't kill my session.*
**Acceptance Criteria:**
- Starting a session triggers an iOS Live Activity.
- Activity updates minimal state (Time, Laps count).
**Tasks:**
- [ ] Integrate `live_activities` flutter package.
- [ ] Build the native Swift UI widget for the Island/Lockscreen representation.
- [ ] Send update events from Flutter every 1 minute to avoid excessive OS throttling.

### US 7.5: Foreground Service (Android)
*As an Android user, I want a persistent notification ensuring my timer remains active in the background for multi-hour sessions.*
**Acceptance Criteria:**
- Starting a session starts a Foreground Service.
- notification shows "Session Active" and cannot be swiped away until session ends.
**Tasks:**
- [ ] Integrate `flutter_foreground_task`.
- [ ] Configure the persistent notification channels and AndroidManifest permissions.

### US 7.6: "Single Active Session" Lock
*As a multi-device user, I want my account to "lock" to one active device per session (via 10-minute heartbeat) so my focus tracking isn't duplicated or conflicted.*
**Acceptance Criteria:**
- Only one device can have an active `start_time` without an `end_time` at a time.
- Attempting to start on Device B while Device A is active yields an alert dialog.
**Tasks:**
- [ ] Add check for "Active Session" flag via Realtime presence or quick DB poll on session launch.
- [ ] Build "Session Already Active on another device" error UI.

### US 7.7: Flicker PB Shader (Experimental)
*As a user, I want to see a subtle 1950s film projector visual effect when viewing my Quality Score card if I hit a new Personal Best.*
**Acceptance Criteria:**
- If finalized session max interval > All-time max interval, apply a custom fragment shader over the Summary screen.
**Tasks:**
- [ ] Write a GLSL fragment shader for Film Grain/Flicker.
- [ ] Load the shader in Flutter via `FragmentProgram`.
- [ ] Apply to `ShaderMask` widget wrapping the summary layout conditionally.

## Epic 8: User Onboarding (The 6-Step Indoctrination)

### US 8.1: The Manifesto
*As a new user, I want to read a one-screen introduction to the "Popcorn Brain" crisis to understand the app's core philosophy.*
**Acceptance Criteria:**
- "Manifesto" screen shown immediately after install/first open.
- Typewriter text effect for narrative immersion.
- Needs manual scroll to bottom before "Accept" button is active.
**Tasks:**
- [ ] Build Onboarding PageView architecture.
- [ ] Implement typewriter animation widget.
- [ ] Add scroll controller listener to unlock the Next button.

### US 8.2: The Lap Mechanic Tutorial
*As a new user, I want a visual tutorial explaining that distractions are "reps" (not failures) to reframe my mindset around focus.*
**Acceptance Criteria:**
- Screen 2 provides an interactive mockup of the "Distracted" button.
- User *must* tap it to proceed to the next screen.
**Tasks:**
- [ ] Build interactive mockup UI.
- [ ] Bind tap event to trigger the `PageView.nextPage()` controller.

### US 8.3: Sensor Calibration
*As a new user, I want a guided setup for the "Face-Down" hardware trigger so the app can reliably detect when I start a session.*
**Acceptance Criteria:**
- Screen 3 asks user to place phone face down on desk.
- App records baseline Gyro/Proximity values and confirms with haptic feedback.
**Tasks:**
- [ ] Read raw sensor data and map baseline XYZ gravity vector.
- [ ] Store baseline vectors in SharedPreferences for later session comparisons.

### US 8.4: Intent Setting Practice
*As a new user, I want to practice writing a "Pre-Flow Intent Statement" so I understand how to set micro-contracts for my sessions.*
**Acceptance Criteria:**
- Screen 4 forces user to type at least 10 characters before proceeding.
**Tasks:**
- [ ] Implement text field and minimal character count validation.

### US 8.5: Baseline Test
*As a new user, I want to complete a short 5-minute focus session to calculate my initial 1-Rep Max (1RM) and familiarize myself with the timer.*
**Acceptance Criteria:**
- Screen 5 runs a hardcoded 5-minute timer.
- Laps are recorded, but standard session termination rules are bypassed for simplicity.
**Tasks:**
- [ ] Build simplified Timer screen mapped to the onboarding flow.
- [ ] Save the resulting data as the first actual entry in local SQLite.

### US 8.6: The Founder's Oath
*As a new user, I want a final privacy overview confirming the local-first commitment so I can trust the app with my data.*
**Acceptance Criteria:**
- Screen 6 explains local-first encryption.
- Final "I Agree" button flags local `has_completed_onboarding = true`.
- Navigates to main app Home screen (`/home`).
**Tasks:**
- [ ] Build static explanatory text UI.
- [ ] Update SharedPreferences flag.
- [ ] PushRouteReplacement to `/home`.

## Epic 9: Data Sync & Offline Integrity

### US 9.1: Zero-Dependency Local Core
*As a user, I want the app to run completely independent of any web server or Wi-Fi, writing all reps and focus metrics directly to my phone's storage so I am never locked out of my own training data.*
**Acceptance Criteria:**
- App can boot, record sessions, and display historical Dashboard charts in "Airplane Mode".
- No loading spinners should block the UI waiting for network requests (excluding absolute initial license check).
**Tasks:**
- [ ] Architect the app state to prioritize SQLite reads over network reads.
- [ ] Add explicit integration tests proving session creation works without an active network interface.

### US 9.2: Delta Syncing
*As an opt-in syncing user, I want only changed or new sessions/laps to be pushed to Supabase when a connection is restored to preserve battery and bandwidth.*
**Acceptance Criteria:**
- A background worker (`workmanager` package) triggers when connectivity is restored.
- Worker runs a `SELECT * WHERE updated_at > last_successful_sync`.
- Only matching rows are pushed to Supabase REST endpoints.
**Tasks:**
- [ ] Implement `connectivity_plus` listener to detect "Back Online" events.
- [ ] Build the Delta Payload constructor logic.
- [ ] Update `last_successful_sync` timestamp globally upon HTTP 200 response.

### US 9.3: Conflict Resolution
*As a multi-device syncing user, I want the app to use a "Last-Write-Wins" strategy based on my client-side timestamps if I log overlapping training laps while offline.*
**Acceptance Criteria:**
- If a cloud record has a newer `updated_at` than the incoming local record for the same ID, the cloud rejects the update.
- The client then pulls the newer cloud record and overwrites its local copy.
**Tasks:**
- [ ] Write Supabase PostgreSQL function to handle `UPSERT` with `updated_at` comparisons.
- [ ] Implement Client-side exception handling to fetch and merge rejected UPSERT rows.

## Epic 10: Mobile Screens & Navigation

### US 10.1: Main Timer Screen (`/home`)
*As a user, I want a centralized home screen displaying the breathing ring, current session context, and the Lap trigger button.*
**Acceptance Criteria:**
- Home route contains bottom navigation bar.
- Primary view is the Breathing Ring, Timer Text, and Lap Button.
**Tasks:**
- [ ] Implement `go_router` or `auto_route` structure.
- [ ] Build the primary Scaffold and BottomNavigationBar.

### US 10.2: Dashboard Screen (`/dashboard`)
*As a user, I want a dedicated dashboard tab to navigate between my daily heatmaps, distraction pie charts, and Focus Density KPIs.*
**Acceptance Criteria:**
- Secondary tab on Bottom Nav.
- Renders a vertically scrolling list of the analytics Cards.
**Tasks:**
- [ ] Build Dashboard Scaffold.
- [ ] Integrate the previously built Analytics widgets into a single reactive view.

### US 10.3: Trophy Room Screen (`/trophies`)
*As a user, I want a sub-screen accessible from the dashboard to view my top 5 all-time 1RMs and historical achievements.*
**Acceptance Criteria:**
- Navigable via a button on the Dashboard.
- Renders the Trophy Room list UI.
**Tasks:**
- [ ] Add `/trophies` named route.
- [ ] Build the Trophy screen Scaffold and list view.

### US 10.4: Settings & Privacy Screen (`/settings`)
*As a paid user, I want a settings screen where I can manage my Cloud Sync toggle, trigger Data Export, or initiate the "Delete My Life" account wipe.*
**Acceptance Criteria:**
- Settings gear icon on top right of Home/Dashboard.
- Renders standard list view with Toggles and Danger Zone buttons.
**Tasks:**
- [ ] Build Settings UI layout.
- [ ] Wire up the underlying functional callbacks (Wipe Data, Export, Sync toggles).

### US 10.5: Forced Paywall Screen (`/paywall`)
*As a free user who has completed one session, I want to see a blocking paywall upon app launch that prevents further usage until I pay or enter a voucher code.*
**Acceptance Criteria:**
- Full-screen scaffold overriding the standard App routing.
- Displays pricing, purchase buttons, and voucher input.
**Tasks:**
- [ ] Implement Paywall Route that does not have a "Back" button.
- [ ] Connect Stripe and Voucher API handlers.

### US 10.6: Post-Session Summary Screen (`/summary`)
*As a user, I want a standalone screen that appears after finishing a session to review my Quality Score card before returning to the home screen.*
**Acceptance Criteria:**
- Pushed onto the navigator stack upon Session completion.
- "Return to Home" button pops the route.
**Tasks:**
- [ ] Build the Summary view containing the generated Score Card widget.

## Epic 11: Web Portal & Legal Pages (Next.js)

### US 11.1: Marketing Landing Page (`/`)
*As a prospective user, I want to see the "Quiet Flex" value proposition, trusted partner logos, and the dynamic scarcity pricing tiers to understand the product.*
**Acceptance Criteria:**
- Next.js index page strictly adheres to "Elegant Noir" design specs (Monochrome, sleek typography).
- Displays animated pricing tiers sourced from Supabase.
**Tasks:**
- [ ] Scaffold Next.js project with TailwindCSS.
- [ ] Build Hero, Value Prop, and dynamic Pricing sections.

### US 11.2: Web Checkout Page (`/checkout`)
*As a buyer, I want to be securely redirected to a Stripe Checkout URL to complete my one-time payment.*
**Acceptance Criteria:**
- Clicking "Buy" redirects to Stripe's hosted Checkout.
**Tasks:**
- [ ] Configure Stripe Payment Links or Checkout Sessions via Next.js API route.

### US 11.3: B2B Coach Dashboard (`/coach-dashboard`)
*As a team manager, I want a secure web route after logging in to view my total seats, generate new voucher codes, and revoke access from departed employees.*
**Acceptance Criteria:**
- Protected route requiring Supabase Auth login.
- Displays table of active seats vs total seats.
**Tasks:**
- [ ] Implement Supabase Auth middleware protecting `/coach-dashboard*`.
- [ ] Build dashboard overview UI.

### US 11.4: B2B Analytics View (`/coach-dashboard/analytics`)
*As a team manager, I want a sub-page within the dashboard to view anonymized, aggregated focus hours for my organization.*
**Acceptance Criteria:**
- Queries the `org_aggregate_stats` view based on the manager's organzation ID.
- Displays simple bar charts of team performance.
**Tasks:**
- [ ] Build Analytics page within the Coach layout.
- [ ] Integrate simple charting library (e.g., Recharts) for the web view.

### US 11.5: Gift Certificate Viewer (`/gift/[voucher-id]`)
*As a gift recipient, I want a unique URL to view my digital certificate and retrieve my 12-digit access key.*
**Acceptance Criteria:**
- Dynamic route rendering a stylish digital certificate.
- Server-side rendering validates the `voucher-id` exists before rendering.
**Tasks:**
- [ ] Build Next.js dynamic route `[id].tsx`.
- [ ] Implement CSS print media queries for perfect PDF/A4 sizing.

### US 11.6: Terms of Service Page (`/legal/terms`)
*As a user or legal auditor, I want a dedicated page clearly outlining the Medical Disclaimers and usage constraints.*
**Acceptance Criteria:**
- Static markdown-rendered page accessible from website footer and App settings.
**Tasks:**
- [ ] Convert legal static copy into Markdown/React component.

### US 11.7: Privacy Policy Page (`/legal/privacy`)
*As a user, I want a detailed page listing all Authorized Data Processors (Supabase, Stripe, etc.) to confirm my data is handled safely.*
**Acceptance Criteria:**
- Details the Local-First architecture and explicit cloud opt-in.
**Tasks:**
- [ ] Draft and format the specific Data Processor clauses.

### US 11.8: Impressum (`/legal/impressum`)
*As a German user or consumer protection agent, I want a legally compliant Impressum page linking to operator details and the EU ODR platform.*
**Acceptance Criteria:**
- Contains corporate ID, VAT, and contact details.
**Tasks:**
- [ ] Add Impressum static page per German telemedia laws.

### US 11.9: Return & Refund Policy (`/legal/refunds`)
*As a buyer, I want a clear policy page explaining the refund limitations regarding digital content.*
**Acceptance Criteria:**
- Explicitly states the 14-day EU digital goods waiver if applicable.
**Tasks:**
- [ ] Finalize refund copy and publish the static route.

## Epic 12: Accessibility & EAA Compliance

### US 12.1: High-Contrast "Noir-White" Mode
*As a visually impaired user, I want a High-Contrast Toggle in Settings that replaces gray outlines with Pure White or Absolute Yellow to meet WCAG 7:1 contrast ratios.*
**Acceptance Criteria:**
- Settings toggle for High-Contrast Mode activates a secondary `ThemeData`.
- All Ligne Claire borders and text switch to #FFFFFF or #FFFD01, maintaining the solid black background.
**Tasks:**
- [ ] Define the high-contrast `ThemeData`.
- [ ] Wire the toggle to the Riverpod theme provider.

### US 12.2: Screen-Reader & VoiceOver Architecture
*As a user relying on screen readers, I want the timer to announce milestones rather than seconds, and all icons to have clear semantic labels so the app is completely navigable via audio.*
**Acceptance Criteria:**
- App utilizes Flutter `Semantics` widgets for all interactive elements.
- The Chronometer component reads out time only at 1-minute or 5-minute intervals.
- All "Pill" icons have explicit semantic labels (e.g., "Distraction: Mobile Phone").
**Tasks:**
- [ ] Wrap Chronometer text in a custom Semantics widget with tailored announcement logic.
- [ ] Audit and apply `semanticLabel` properties to all buttons, pills, and touch targets.

### US 12.3: Motor Impairment & Navigation
*As a user with motor control difficulties, I want all buttons (especially the Distracted button) to have a minimum 48x48dp touch target and a manual fallback for the Face-Down trigger.*
**Acceptance Criteria:**
- Minimum touch target for any interactive element is 48x48dp.
- A "Manual Start" button is always present as a fallback for the Face-Down gesture.
**Tasks:**
- [ ] Conduct UI dimension audit to ensure 48dp minimums.
- [ ] Build the Manual "Start" fallback button on the setup screen.

### US 12.4: Dyslexia-Friendly Typography
*As a dyslexic user, I want an option to switch the body text to OpenDyslexic without breaking the "classy" layout of the app.*
**Acceptance Criteria:**
- Typography setting allows toggling between standard font (Montserrat/Inter) and OpenDyslexic.
- Layout remains intact without shifting or breaking boundaries.
**Tasks:**
- [ ] Add the OpenDyslexic font asset to the project.
- [ ] Implement font-family toggle linked to the global text theme provider.

### US 12.5: Accessibility Statement (EAA Audit Trail)
*As an auditor or B2B client, I want an Accessibility Statement in the "About" section detailing the app's WCAG 2.1 Level AA compliance status.*
**Acceptance Criteria:**
- A static page accessible from Settings > About > Accessibility Statement.
**Tasks:**
- [ ] Draft the boilerplate Accessibility Statement Markdown.
- [ ] Render it via the legal documents Markdown viewer.

## Epic 13: Phase 4 Expansions (Visual RPG, Audio, & B2B)

### US 13.1: The Acoustic Gym (Soundscapes)
*As a user, I want integrated lo-fi, brown noise, or binaural beats that play automatically during my session to anchor my focus.*
**Acceptance Criteria:**
- A sound mixer icon in the session setup allows selecting a "Focus Texture" (e.g., Brown Noise, Rain, Typewriter).
- Audio loops continuously while the timer is running and pauses cleanly during breaks or app exit.
**Tasks:**
- [ ] Integrate an audio playback package (e.g., `just_audio`).
- [ ] Build the Soundscape selector UI.
- [ ] Link audio playback to the `FocusTimerBLoC` run states.

### US 13.2: Study Lounges (Co-Working Rooms)
*As a user missing library accountability, I want to join high-fidelity, Noir-themed digital rooms (max 25 people) for synchronized, silent focus sessions.*
**Acceptance Criteria:**
- Shows "Ghost Avatars" (silhouettes) of other users with progress rings above them.
- Chat is disabled entirely during focus blocks, opening only for a 5-minute break every hour.
- Synced audio/radio station for the room.
**Tasks:**
- [ ] Build Supabase Realtime presence channel for the Lounge.
- [ ] Create the visual "Ghost Avatar" and synchronization state logic.

### US 13.3: Focus Battles (Competitive Deep Work)
*As a competitive user, I want to duel a friend in a "60-minute Sprint" where the winner is determined by Quality Score (Density x Resilience), not just raw time.*
**Acceptance Criteria:**
- Users can send a challenge link to a friend.
- Both users enter the session. The one with the highest calculated Quality Score wins "Founder Points" or UI skins.
**Tasks:**
- [ ] Implement challenge invitation flow (Deep Link).
- [ ] Build post-session comparison UI calculating the winner.

### US 13.4: Global Focus Leaderboards
*As a user motivated by rankings, I want to see weekly resetting leaderboards for Most Minutes ("The Tank") and Highest Resilience ("The Monk").*
**Acceptance Criteria:**
- A Leaderboard tab pulling aggregated data from the last 7 days.
- B2B Private Leaderboards option for verified organizations.
**Tasks:**
- [ ] Create Supabase RPCs/Views to aggregate weekly stats securely.
- [ ] Build the Leaderboard UI with distinct metric tabs.

### US 13.5: The "Brain Muscle" Evolution (Visual RPG)
*As a user, I want my profile's "Statue of the Mind" to physically evolve from a rough sketch to an inked masterpiece as my 1RM increases, and slowly atrophy if I skip training.*
**Acceptance Criteria:**
- Profile screen contains a dynamic SVGs/Rive animation of a statue.
- The detail state is tied to the historical 1RM.
- If days since last session > 14, the detail state drops 1 tier.
**Tasks:**
- [ ] Integrate Rive animations or a stepped SVG rendering system.
- [ ] Define the thresholds for Statue evolution based on 1RM.

### US 13.6: Fetch from Calendar/Reminders
*As a busy professional, I want to retrieve my current calendar event or top Reminder task with one tap to act as my Intent Statement, reducing pre-session typing.*
**Acceptance Criteria:**
- Setup screen has an "Import Task" button mapping to native Calendar/Reminders APIs.
- The active time-block's title auto-fills the Intent text field.
**Tasks:**
- [ ] Implement `device_calendar` or similar bridge package.
- [ ] Build Permission request flow for Calendar access.

### US 13.7: The "Focus Resume" (Export)
*As a student or contractor, I want to generate a "Focus Resume" PDF outlining my 1RM, Resilience Score, and Deep Work hours to prove my reliable productivity.*
**Acceptance Criteria:**
- Settings > Generate Resume produces a designed PDF utilizing the Vintage Seal layout.
**Tasks:**
- [ ] Utilize the `pdf` flutter package to draw the document.
- [ ] Include aggregated historical KPIs dynamically in the document.



Phase 2: Data Layer — Drift Encrypted SQLite
Define Drift tables: sessions, laps, settings
 Write SessionDao and LapDao
 Integrate flutter_secure_storage encryption key
 Wire database into Riverpod providers
 Persist session on finish; load history for dashboard
Phase 3: Coach Logic
 Silent week / baseline check (≥10 sessions)
 +5% Next Aim algorithm
 De-load trigger detection
Phase 4: Sensor Integration
 Face-down start via sensors_plus (accelerometer)
 Zombie session detection + recovery modal
Phase 5: Notification Service
 Local push reminders via flutter_local_notifications
 Notification channels setup
Phase 6: Dashboard Charts
 24h circular heatmap (CustomPainter)
 Distraction trigger doughnut (fl_chart)
 1RM trend line chart
Phase 7: Cloud Sync (optional Supabase)
 Supabase client + anon key config
 RLS policies for user data
 Async sync of sessions/laps to Supabase
 Opt-in toggle in Settings



 🔴 Priority 1 — Must-Do Before Shipping
Item	Where	What it needs
Run flutter pub get	Terminal	Required for new flutter_timezone + http packages
Settings → Wipe All Data	

settings_screen.dart
 line 188	// TODO: implement full DB teardown — needs dao.deleteAll() call
Settings → Export Data	

settings_screen.dart
 line 81	onTap: () {} — needs to call ExportService (already written in 

export_service.dart
)
Settings → Reminder Time	

settings_screen.dart
No time-picker UI at all — needed for 

scheduleDailyReminder(time:)
 to be called
Settings → Cloud Sync credentials	

settings_screen.dart
Toggle exists but no URL/key input form for Supabase
🟡 Priority 2 — Polish & UX
Item	Where	What it needs
Face-down auto-start	

timer_screen.dart
faceDownStartProvider is defined but never ref.listen'd in the timer/setup screen
/timer route guard	

router.dart
Nothing stops a user navigating to /timer with no active session — would show a blank/broken state
Paywall screen	

paywall_screen.dart
Exists as a file but the "Upgrade" button in Settings is a no-op
Settings toggles → persisted	settingsProvider	Currently in-memory only (lost on restart) — should save to 

AppSettings
 DB table
🟢 Priority 3 — Optional / Nice-to-Have
Item	Detail
App icon + splash	Default Flutter icon still showing
Android SCHEDULE_EXACT_ALARM permission	Required on Android 12+ for zonedSchedule with exactAllowWhileIdle
/timer → /summary route guard on back-press	Currently allows back-navigation out of an active session

 "Priority 1 & 2":

Run flutter pub get and flutter test on your end.
We finish wiring the Settings Screen (Wipe Data, Export Data, Reminder Time, Supabase credentials).
We connect the Face-down auto-start sensor to the setup screen.