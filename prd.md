# Billi — Product Requirements Document

## Executive Summary

Billi is a **desktop-first, responsive travel budget planner**. Users create trips, set preferences, receive cost-of-living–based budget estimates, track expenses, and optionally split costs with others. Primary users are solo travelers and couples/groups who want cost visibility and expense tracking.

**v1 scope**: Trip creation with city-based destination selection, preference-driven budget generation, expense logging, global ledger with trip filter, live budget updates via Turbo, multi-currency (trip base + FX display), and pricing for all cities (real snapshot or labeled mock). Friends & Billing (participants, who-paid, settlements) and AI explanations are **deferred** to a later phase.

**Current state**: Core trip and budget flow works. Expense CRUD and ledger work. Several bugs and gaps block market-ready: destination is free-text (no city dropdown), no live preference→budget update in UI, Friends & Billing uses wrong column (`payer_id` vs `payer_participant_id`), trip creator is not auto-created as participant, mock snapshot keys don’t match pricing logic, and Turbo Stream preference response has no DOM target.

---

## Product Goals (v1)

1. **Trip planning**: Create trips with destination (city from supported list), dates, and traveler count; set preferences (lodging, food, activities, shopping); get a single budget estimate.
2. **Budget transparency**: Show budget breakdown by category; update budget in-place when preferences change (no full-page reload).
3. **Expense tracking**: Log expenses per trip with category, amount, date; optional payer when relevant; view all expenses in a global ledger with trip filter.
4. **Pricing for every city**: Every supported city shows pricing—either latest real snapshot or high-quality, timestamped mock, clearly labeled.
5. **Multi-currency**: Trip has a base currency; display converted amounts in a chosen display currency; no historical FX accuracy required.
6. **Stable, predictable UX**: Desktop-first, responsive; no broken flows; fix known bugs and remove or complete dead code paths.

---

## Non-Goals / Deferred Features

- **Friends & Billing**: Invite participants, “who paid,” balance calculation, settlement plan. Data model exists; UI and logic are incomplete and buggy; explicitly **out of v1**.
- **AI budget explanations**: Real AI (e.g. OpenAI) integration. Stub only for v1.
- **TripBudgetItem / TripPreferenceItem**: Itemized budget or preference storage. Use existing scalar columns only; item tables deferred.
- **Email invitations**: No invite-by-email flow; owner can add participants by name/email manually when that feature ships.
- **Background jobs**: Sidekiq not required for v1; snapshot refresh can be request-based.
- **Accessibility / i18n**: Not required for first market-ready version.

---

## Target Users & Use Cases

| User type | Primary use case |
|-----------|-------------------|
| Solo traveler | Plan a trip, set preferences, get a realistic budget, track spending. |
| Couple / small group | Same as above; optional expense logging; splitting deferred to later. |
| Group (future) | Visibility into who paid and who owes; settlement plan (post-v1). |

v1 must fully support solo and couples; groups are supported only for trip creation and expense logging, not for splitting or settlements.

---

## Core User Flows

### Trip creation

1. User clicks “Plan a new trip.”
2. **Step 1**: Enters trip name; selects **destination from autocomplete/dropdown** (source: `cities` table); enters start/end dates and traveler count; submits.
3. **Step 2**: Sets preferences (lodging style, hotel/Airbnb nights, meal counts, activities, nightlife, shopping level, notes); submits.
4. System generates budget (BudgetGenerator + PricingProvider); user is redirected to trip show.
5. **Trip creator is automatically created as a TripParticipant** (for future splitting; no UI required in v1 beyond data correctness).

**Constraints**: Destination must be a supported city. No free-text city/country for v1.

### Budget generation

1. Budget is generated after preference step (wizard) or when preferences are updated.
2. Pricing: resolve city by destination; use latest `PriceSnapshot` for that city if present; otherwise use **mock data** (timestamped, labeled) so every city has pricing.
3. Budget is stored in `TripBudget` (existing scalar columns); displayed as total + per-person + category breakdown.
4. **Live update**: When user changes preferences (e.g. in a dedicated preferences panel on trip show), request is sent via Turbo (e.g. PATCH preference); server recalculates budget and returns Turbo Stream that replaces the budget breakdown DOM; no full-page reload.

### Expense logging

1. User adds expense from trip show (Overview tab) or from Ledger (with trip selected).
2. Required: category, amount, date. Optional: description, payer (trip participant).
3. Expense is stored on the trip; appears in trip timeline and in Ledger.
4. Ledger: **global** list of expenses across trips; filter by trip. Summary cards: total spent, planned budget, remaining (for selected trip when applicable).

### Optional splitting

- **v1**: Data model (Expense ↔ payer_participant, Split, TripParticipant) remains. No requirement to implement “who paid,” balances, or settlements. If any UI exposes payer, it must use `payer_participant_id` correctly.
- **Later**: Full Friends & Billing: add participants, assign payer per expense, equal/custom splits, balance and settlement plan.

---

## Data & Pricing Strategy

- **Cities**: Supported cities in `cities` table (seeded). Trip destination is a **city selection**, not free text (v1).
- **Pricing**: 
  - **Primary**: Latest `PriceSnapshot` for the selected city (source: TravelTables API or existing preload). `PricingProvider::Snapshot` reads `snapshot.data` (jsonb).
  - **Fallback**: If no snapshot, use **mock data** so every city shows pricing. Mock must be timestamped and clearly labeled (e.g. “Estimated from averages” + date). Mock keys must align with what `PricingProvider::Snapshot` (or a dedicated mock provider) expects (e.g. `food_cheap_meal`, `stay_rent_1br_center_month`), or pricing layer must accept a unified key set.
- **Currency**: Trip has base currency. Display currency can differ; FX conversion for display only; no historical FX accuracy for v1.
- **Budget storage**: v1 uses existing `TripBudget` scalar columns only. `TripBudgetItem` / `TripPreferenceItem` are not used in v1.

---

## UX & Interaction Model

- **Desktop-first**: Layout and primary flows designed for desktop; responsive for mobile web.
- **Live budget update**: Preference change must update budget in place via Turbo Streams (replace a single DOM region, e.g. `#budget_breakdown`). No full-page reload for preference edits that trigger recalculation.
- **Landing**: “View Demo” redirects to sign-in (no separate demo account or tour required for v1).
- **Ledger**: One global view; trip filter (dropdown); when a trip is selected, summary cards and expense list reflect that trip; “Add Expense” can link to trip or open inline/modal as implemented.
- **Navigation**: Sidebar (Trips, Ledger, Friends & Billing, profile). Friends & Billing can remain in nav; content can be “Coming later” or minimal placeholder for v1.

---

## Current Codebase Reality

### What works

- **Auth**: Devise sign up, sign in, edit registration (name, avatar). Landing when logged out; redirect to trips when logged in.
- **Trips**: CRUD; wizard (new → step 2 preferences → generate budget → show). Trip show with tabs (Overview, Budget & Preferences, Collaborators).
- **Budget**: BudgetGenerator + PricingProvider (Snapshot from `PriceSnapshot.data` or Static fallback). Display of total, per-person, and category breakdown on trip show and in overview/budget tabs.
- **Expenses**: Create/destroy from trip overview and from Ledger; list and filter by trip; summary cards (total spent, planned budget, remaining).
- **Featured cities**: Trips index shows featured city snapshots when snapshots exist; city card uses `snapshot.items` or `snapshot.data`.
- **Seeds**: Users, cities, sample trip with preference; no budget run in seeds (snapshots may be missing).
- **Cost-of-living pipeline**: `cost_of_living:preload_initial_snapshots`; TravelTablesClient; NormalizeTravelTables; UpdateCitySnapshot (writes jsonb + items). Rate limiting and caching in place.

### What is incomplete

- **Destination selection**: Trip form uses free-text `destination_city` and `destination_country`. No autocomplete/dropdown from `cities` table; mismatches prevent reliable pricing lookup.
- **Live budget update**: TripPreferencesController supports `format.turbo_stream` and replaces `#budget_breakdown`, but **no view renders a DOM element with `id="budget_breakdown"`**, and no inline preference form on trip show submits via Turbo to this endpoint. Preference editing is only via full wizard (full-page). So “live” preference→budget update is **dead code**.
- **Trip creator as participant**: Trip has `trip_participants`; no code creates a participant for the trip owner. Required for future splitting and data consistency.
- **Multi-currency**: Trip has `currency`; no display-currency or FX conversion in UI or services.
- **Mock pricing**: `GenerateMockSnapshot` exists but uses keys that don’t match `PricingProvider::Snapshot` / NormalizeTravelTables (e.g. `meal_inexpensive_restaurant` vs `food_cheap_meal`). So mock snapshots don’t drive current budget math. No “all cities must show pricing” path with labeled mock.

### Known bugs and gaps

1. **FriendsController**: Uses `@expenses.where(payer_id: participant.id)`. Expense has no `payer_id` column; it has `payer_participant_id`. Query is wrong; balances/settlements would be incorrect or failing. Must use `payer_participant_id`.
2. **Wizard shopping level**: Form offers `low`, `medium`, `high`, `luxury`. `TripPreference` enum for `shopping_budget_level` only has `low`, `medium`, `high`. Submitting “luxury” can raise invalid enum error. Either add `luxury` to enum or remove it from the form for v1.
3. **Expense payer**: Expense form and `expense_params` do not include `payer_participant_id`. Payer cannot be set in UI. Optional for v1 but must be correct if ever exposed.
4. **Participants**: No UI to add trip participants; “Invite Friend” is disabled. For v1, only “trip creator as participant” is required; no full Friends & Billing.

### Dead or unused code paths

- **Turbo Stream preference update**: `TripPreferencesController#update` with `format.turbo_stream` and `update.turbo_stream.erb` (replace `#budget_breakdown`). No element `#budget_breakdown` in any view; no form posts to preference update with Turbo. Either add the DOM target and an inline preference form that submits with Turbo, or remove/repurpose this response.
- **TripBudgetItem / TripPreferenceItem**: Tables and models exist; BudgetGenerator and preferences use only scalar columns. Explicitly deferred; no v1 implementation required.
- **PriceEstimator**: Alternative budget calculator (static BASE_RATES); not used by main flow (BudgetGenerator uses PricingProvider). Can remain as legacy or be removed per team decision.
- **AiBudgetExplainer**: Stub only; no OpenAI. Keep for v1; no integration required.

---

## Gaps to Reach Market-Ready

1. **Destination**: Replace free-text city/country with city autocomplete or dropdown sourced from `cities`; ensure trip stores a selected city (e.g. `city_id` or consistent `destination_city`/`destination_country` from city record) so pricing always resolves.
2. **Pricing for all cities**: Implement “no snapshot → mock” path: either align `GenerateMockSnapshot` (or a new mock) with the keys expected by pricing layer, or add a Mock pricing provider that returns the same key set; ensure mock is timestamped and labeled in UI.
3. **Live budget update**: Add a DOM container (e.g. `div#budget_breakdown`) that wraps the budget breakdown partial on trip show (e.g. in Budget tab or Overview); add an inline preference form (or link to a slide-over/modal) that PATCHes to `trip_preference_path` with `Accept: text/vnd.turbo-stream.html` (or equivalent) so Turbo Stream replace works. Ensure server recalculates budget and returns the updated partial.
4. **Bugs**: Fix FriendsController to use `payer_participant_id`. Resolve wizard shopping level (enum vs form). Optionally allow expense payer in params and UI if desired for v1.
5. **Trip creator as participant**: On trip creation (or first load), ensure the trip’s user is represented as a `TripParticipant` (e.g. `user_id` set, `is_user: true`). No UI required for v1.
6. **Multi-currency**: Add display currency (user preference or trip-level); use a simple FX rate source (e.g. one rate per trip currency → display currency); show amounts in display currency where appropriate. No historical accuracy.
7. **Landing**: “View Demo” → redirect to sign-in (or demo sign-in if added later).
8. **Cleanup**: Remove or document Turbo Stream preference response if not used; optionally remove or isolate PriceEstimator; keep AiBudgetExplainer as stub.

---

## Milestones

### v1 stabilization

- Fix known bugs: FriendsController `payer_participant_id`; wizard shopping level enum/form.
- Destination: city autocomplete/dropdown from `cities`; trip linked to selected city for pricing.
- Trip creator created as TripParticipant on trip creation.
- Optional: expense payer in params and in add-expense form (dropdown of participants).

**Exit criteria**: No crashes from enum or column names; every new trip has a resolvable city for pricing; creator is a participant.

### Market-ready release

- Pricing for all cities: real snapshot or labeled, timestamped mock; unified key set and provider behavior.
- Live budget update: DOM target for `#budget_breakdown`; inline (or minimal) preference form submitting via Turbo; budget recalculated and streamed.
- Multi-currency: trip base currency; display currency and FX conversion for display only.
- Landing: “View Demo” → sign-in.
- Ledger: global view with trip filter; behavior already largely in place; verify and polish.
- QA: Full flows (create trip → preferences → budget → add expense → ledger); desktop and responsive; no dead or broken preference-update path.

**Exit criteria**: All v1 product goals met; no known blocking bugs; pricing and currency behavior documented.

### Post-v1 phase

- Friends & Billing: add/edit participants, “who paid” per expense, equal/custom splits, balance and settlement plan. Fix and complete existing controller/views.
- AI budget explanations: integrate OpenAI (or agreed provider) behind AiBudgetExplainer.
- Optional: TripBudgetItem / TripPreferenceItem for itemized budget or preferences; email invitations; background snapshot refresh; accessibility and i18n.

---

*This PRD is the single source of truth for v1 scope and for reaching market-ready. Decisions marked LOCKED should not be changed without a formal scope change.*
