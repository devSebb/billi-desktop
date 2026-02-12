# Billi — Full Codebase Audit & Report

**Generated:** February 2026  
**Scope:** Purpose, tech stack, connections, design, layout, theme, and functionality (no minute detail omitted).

---

## 1. Purpose of the Application

**Billi** is a **desktop-first, responsive travel budget planner**. It allows users to:

- **Plan trips** with a city-based destination, dates, and traveler count.
- **Set preferences** (lodging style, hotel/Airbnb nights, meal types, activities, nightlife, shopping level).
- **Receive cost-of-living–based budget estimates** (real API data or labeled mock data per city).
- **Track expenses** per trip with category, amount, date; optional payer (trip participant).
- **View a global ledger** of expenses with trip filter and summary cards (total spent, planned budget, remaining).
- **Optionally use multi-currency**: trip base currency + user display currency with simple FX conversion for display only.

**Target users (v1):** Solo travelers and couples/small groups who want cost visibility and expense tracking. Friends & Billing (participants, who-paid, settlements) is **deferred**; data model exists but UI is placeholder or “Coming later.”

**Product source of truth:** `prd.md` in the repo root.

---

## 2. What the App Uses (Tech Stack)

### 2.1 Backend

| Technology | Version / Notes |
|------------|------------------|
| **Ruby** | Version in `.ruby-version` |
| **Rails** | 7.2.2+ |
| **Database** | PostgreSQL (`pg` ~> 1.1), UUID primary keys, `pgcrypto` extension |
| **Auth** | Devise (registerable, recoverable, rememberable, validatable) |
| **File uploads** | Active Storage (with `image_processing` for variants); user avatars |
| **Background jobs** | Sidekiq (mounted at `/sidekiq` when authenticated); not required for v1 per PRD |
| **Redis** | Used by Action Cable (and Sidekiq if enabled); `config/cable.yml` |

### 2.2 Frontend

| Technology | Usage |
|------------|--------|
| **Tailwind CSS** | Full styling via `app/assets/tailwind/application.css`; custom theme and design tokens |
| **Hotwire** | Turbo (SPA-like navigation, Turbo Streams for live budget update); Stimulus (modest JS) |
| **Import maps** | No npm; JS via `importmap-rails` (Turbo, Stimulus, app controllers) |
| **Stimulus controllers** | `theme_controller.js` (dark/light toggle), `hello_controller.js`, `autosave_controller.js` |

### 2.3 External Services & Gems

| Dependency | Purpose |
|------------|--------|
| **Unsplash** | Trip cover images and city images (search by city name); requires `UNSPLASH_ACCESS_KEY` (and optionally `UNSPLASH_SECRET`) in `.env` |
| **RapidAPI Cost of Living** | Cost-of-living data per city; `TravelTablesClient` calls `cost-of-living-and-prices.p.rapidapi.com`; requires `RAPIDAPI_COST_LIVING_KEY`, `RAPIDAPI_COST_LIVING_HOST`; optional `COST_OF_LIVING_SKIP_SSL_VERIFY=1` for macOS SSL workaround |
| **dotenv-rails** | Loads `.env` in development/test |
| **ostruct** | Used in codebase where needed |
| **jbuilder** | JSON APIs if used |
| **brakeman** | Security scanning (dev/test) |
| **rubocop-rails-omakase** | Ruby style |
| **RSpec, Factory Bot, Faker** | Testing |

---

## 3. All Connections (Data, APIs, Storage)

### 3.1 Database (PostgreSQL)

- **Database names:** `billi_development`, `billi_test`, `billi_production` (production uses `BILLI_DATABASE_PASSWORD`).
- **Main tables and relationships:**
  - **users** — Devise; `name`, `display_currency` (default USD); `has_one_attached :avatar`.
  - **trips** — `user_id`, `name`, `destination_city`, `destination_country`, `start_date`, `end_date`, `travelers_count`, `currency`, `status`, `image_url`.
  - **trip_preferences** — 1:1 trip; lodging_style, hotel_nights, airbnb_nights, meal counts, activities_count, nightlife_nights, shopping_budget_level, overall_comfort_level, notes.
  - **trip_budgets** — 1:1 trip; total_trip_cost, per_person_cost, lodging_total, restaurants_total, activities_total, drinks_total, shopping_total, other_total, currency.
  - **expenses** — trip_id, category, amount, currency, spent_at, description, payer_participant_id (optional FK to trip_participants).
  - **trip_participants** — trip_id, user_id (optional), name, email, is_user; trip owner is auto-created as participant on trip creation.
  - **splits** — expense_id, trip_participant_id, amount, split_type (fixed/equal/percentage), weight; for future splitting.
  - **cities** — name, country, slug; seeded; used for destination dropdown and pricing lookup.
  - **price_snapshots** — city_id, source (`traveltables` or `estimated`), currency, jsonb `data`, collected_at; stores cost-of-living data.
  - **price_snapshot_items** — price_snapshot_id, city_id, category, amount, currency, source, collected_at; normalized rows from snapshot data.
  - **trip_budget_items** / **trip_preference_items** — present in schema but **not used in v1** (scalar columns only).
  - **active_storage_*** — Blobs and attachments for user avatars.

### 3.2 External APIs

- **Unsplash API**  
  - Used in `ApplicationHelper#city_image_url` (cached 7 days per city) and in `Trip#set_image_url` (trip cover).  
  - Requires `UNSPLASH_ACCESS_KEY` in `.env` (or config).

- **RapidAPI Cost of Living (TravelTables)**  
  - `CostOfLiving::TravelTablesClient#fetch_city_costs(city_name, country_name)` → GET to `https://cost-of-living-and-prices.p.rapidapi.com/prices`.  
  - Response normalized by `CostOfLiving::NormalizeTravelTables` (maps API item names to internal keys, e.g. `food_cheap_meal`, `stay_rent_1br_center_month`).  
  - `CostOfLiving::UpdateCitySnapshot` creates a `PriceSnapshot` with `source: "traveltables"` and populates `snapshot.data` + `snapshot.items`.  
  - Rate limiting: 429 handled via `CostOfLiving::RateLimitError`; rake task stops and advises retry.  
  - Caching: in development/test, raw API response cached 12 hours per city.

### 3.3 Redis

- Used for Action Cable (and Sidekiq if configured). No Kredis in use currently.

### 3.4 File Storage

- Active Storage: local or cloud per `config/storage.yml`; used for user avatars (variant resize 200×200).

### 3.5 Environment Variables (.env)

- `UNSPLASH_ACCESS_KEY`, `UNSPLASH_SECRET` — Unsplash.
- `RAPIDAPI_COST_LIVING_KEY`, `RAPIDAPI_COST_LIVING_HOST` — Cost of Living API.
- `COST_OF_LIVING_SKIP_SSL_VERIFY=1` — Optional macOS SSL workaround.

---

## 4. Design and Layout — Landing Page

**File:** `app/views/pages/home.html.erb`  
**Route:** `root to: 'pages#home'`  
**Behavior:** If user is signed in, `PagesController#home` redirects to `trips_path`. Otherwise the landing is rendered (no sidebar/topbar).

### 4.1 Structure and Layout

- **Navbar (fixed top)**  
  - Full width, `z-50`, border-b, `bg-brand-yellow/95 backdrop-blur-lg`.  
  - Logo: “B” in a rounded square (brand-charcoal bg, brand-yellow text), “Billi” text.  
  - Right: “Log in” (link), “Get started” (primary CTA: white text on brand-charcoal, rounded-xl, shadow).

- **Hero section**  
  - Full viewport height; `bg-brand-yellow`, decorative blurs (white/10, brand-teal/20).  
  - Two-column grid (max-w-screen-xl):  
    - **Left (col-span-5):** Headline “Plan trips like a pro. Without the stress.” (brand-charcoal, block “Without the stress.” in white with drop-shadow). Subtext about smart data, split costs, track spending.  
    - **CTAs:** “Start Planning” (primary button with arrow icon, shadow and hover translate), “View Demo” (outline, links to sign-in).  
  - **Right (col-span-7, hidden on small):**  
    - Phone mockup: rounded frame, charcoal border, inner “Rio Trip” UI with Total Budget $2,450, progress bar, sample rows (Flights $850, Hotel $1,200).  
    - Desktop card mockup behind: rounded-2xl, border-2 brand-charcoal, placeholder blocks and colored teal/yellow rectangles.

- **How it works**  
  - Section `bg-brand-charcoal`, py-24.  
  - Heading: “From idea to itinerary in minutes.”; subtext “Billi handles the math…”.  
  - Three steps in grid:  
    1. Pick a Destination (icon in yellow rounded-2xl, -rotate-3).  
    2. Tune Preferences (teal box, rotate-3).  
    3. Share & Split (white box, -rotate-1).  
  - Each: icon, title, short description; hover scale on icon.

- **Footer**  
  - Same charcoal, border-t white/10; logo + “Billi”; copyright “© [year] Billi App. All rights reserved.”

### 4.2 Landing Theme

- **Colors:** Brand yellow (`#F7B500`), brand charcoal (`#1F2933`), brand teal (`#00A8A8`), white.  
- **Typography:** Bold headlines, medium body; no custom font file in landing (relies on Tailwind/theme).  
- **Effects:** Backdrop blur on nav; soft blurs in hero; box shadows and slight rotations on mockups; hover translate on primary CTA.

---

## 5. Design and Layout — Application (Signed-In)

**Layout:** `app/views/layouts/application.html.erb`  
When `user_signed_in?`: flex container with **sidebar** (fixed left) + **main** (topbar + content). When not signed in, only `yield` (landing or Devise pages).

### 5.1 Sidebar (`shared/_sidebar.html.erb`)

- **Position:** Fixed, full height, `w-64`, `z-50`; border-r; light: `bg-billi-surface`, dark: `bg-billi-bg-dark`.
- **Header:** Logo “B” (brand-yellow, rounded-lg) + “Billi” text (text-primary), border-b.
- **Nav (flex-1):**  
  - **Trips** — `trips_path`; active when current path is trips or starts with `/trips`; icon + label; active state: `bg-brand-yellow/10` (dark: `/20`), font-bold.  
  - **Ledger** — `ledger_path` (expenses#index); active state uses brand-teal.  
  - **Friends & Billing** — `friends_path`; same active style as Trips.
- **Footer:** User block — link to `edit_user_registration_path`: avatar (helper `user_avatar`), name or email prefix, “View Profile”, chevron.

### 5.2 Topbar (`shared/_topbar.html.erb`)

- **Height:** h-20; sticky top, border-b; `bg-billi-surface/95` (dark: `bg-billi-bg-dark/95`), backdrop-blur-sm.
- **Left:** Page title from `content_for(:header_title)` or “Dashboard”.
- **Right:**  
  - Search input (placeholder “Search trips…”, w-64, `.input`); non-functional (no controller wired).  
  - Theme toggle button (Stimulus `theme#toggle`): moon (light mode) / sun (dark mode).  
  - Notifications icon with yellow dot (no backend).  
  - Divider.  
  - “Log out” button (delete session).

### 5.3 Main Content Area

- **Wrapper:** `flex-1 ml-64`, then topbar, then `<main class="p-8 md:p-8 lg:p-10 max-w-[1600px]">`.
- **Flash:** Notice (green) and Alert (red) boxes with icon and rounded-xl.
- **Yield:** Page content.

### 5.4 Per-Page Layout (Summary)

- **Trips index:** Header “My Trips”; “Featured cities” horizontal scroll of city snapshot cards (link to `city_path(slug)`); grid of trip cards + “Plan a new trip” dashed card; empty state with CTA.
- **Trip show:** Header card (destination, dates, nights, travelers, Edit/Recalculate); tabs (Overview | Budget & Preferences | Collaborators); tab content.
- **Trip new:** Step indicator (1–2–3); form: name, city dropdown, dates, travelers_count; Next: Preferences.
- **Wizard step 2:** Step indicator; large form: Accommodation (lodging_style radios, hotel/airbnb nights), Food (fancy/casual/street counts), Activities & Fun, Shopping (low/medium/high/luxury), notes; “Generate Budget”.
- **Trip edit:** Same fields as new + currency; Danger Zone delete trip.
- **Ledger:** Trip filter dropdown (form GET); when trip selected: three summary cards (Total Spent, Planned Budget, Remaining); table of expenses (date, description, category, amount, Delete); “Add Expense” links to trip.
- **Friends & Billing:** Trip filter; when trip selected: “Balances” card (per participant: paid, balance, gets back/owes/settled); “Settlement Plan” card (from/to/amount); “Copy summary” button (no implementation).
- **Cities show:** Hero with city image (Unsplash) or gradient; badge “Real data” / “Estimated”; currency label; list of average costs from CityCostPresenter.
- **Devise sign-in:** Full-screen brand-yellow; centered card with logo “B”, “Welcome back”, form (email, password, remember me), “Log in”; links to Sign up and Back to Home.
- **Devise registrations edit:** “Account Settings”; card with Profile (avatar upload, name, email, display_currency), Security (password change), current password; Danger Zone “Delete my account”.

---

## 6. Theme and Design System

**File:** `app/assets/tailwind/application.css`  
**Dark mode:** Class-based; `.dark` on `<html>`; applied by Stimulus theme controller (toggle + localStorage `billi-theme`; fallback `prefers-color-scheme`).

### 6.1 Theme Configuration (@theme)

- **Brand:**  
  - `--color-brand-yellow: #F7B500`  
  - `--color-brand-charcoal: #1F2933`  
  - `--color-brand-teal: #00A8A8`
- **Semantic text:**  
  - `--color-billi-ink`, `--color-billi-ink-muted` (light);  
  - `--color-billi-cream`, `--color-billi-cream-muted` (dark).
- **Surfaces:**  
  - `--color-billi-bg`, `--color-billi-bg-muted`, `--color-billi-surface` (light);  
  - `--color-billi-bg-dark`, `--color-billi-surface-dark` (dark).
- **Font:** `--font-sans: 'Satoshi', system-ui, Inter, sans-serif`.

### 6.2 Base Layer (CSS Variables)

- `:root` and `.dark` set `--billi-bg-page`, `--billi-bg-surface`, `--billi-border`, `--billi-text`, `--billi-text-muted`, `--billi-success`, `--billi-warn`, `--billi-error` for consistent theming.

### 6.3 Component Classes (@layer components)

- **Typography:** `.text-primary`, `.text-muted`, `.page-title`, `.section-title`, `.card-title`, `.label`, `.help-text`, `.caption`.
- **Buttons:** `.btn-primary`, `.btn-secondary`, `.btn-ghost`, `.btn-danger`, `.btn-icon`, `.btn-sm`, `.btn-lg` (focus-visible ring brand-yellow).
- **Inputs:** `.input`, `.input--error`; select/textarea variants.
- **Cards/sections:** `.card`, `.card--bordered`, `.section`, `.section-gap`.
- **Badges:** `.badge`, `.badge--muted`, `.badge--accent`, `.badge--teal`, `.badge--success`, `.badge--error`.
- **Tabs:** `.tabs`, `.tabs__item`, `.tabs__item--active` (active = border-brand-yellow).

### 6.4 Body

- `data-controller="theme"` on `<body>`; `bg-billi-bg dark:bg-billi-bg-dark`, `text-billi-ink dark:text-billi-cream`, `selection:bg-brand-yellow selection:text-brand-charcoal`, `min-h-screen`.

---

## 7. Functionality (Detailed)

### 7.1 Authentication

- **Devise:** Sign up (email, password, name), sign in, sign out, forgot password, remember me.
- **Permitted params:** sign_up → `:name`; account_update → `:name`, `:avatar`, `:display_currency`.
- **Redirect:** After sign-in, redirect to trips (or stored location). Root when signed in → trips.
- **Edit registration:** Profile (avatar, name, email, display_currency), change password, delete account (Danger Zone).
- **Browser support:** `allow_browser versions: :modern` in ApplicationController.

### 7.2 Trips

- **Index:** Lists current_user’s trips (created_at desc); featured city snapshots from `FeaturedCitySnapshots` (up to 10); each trip card: image (Unsplash or gradient), destination, name, dates, travelers pill, estimated budget (display currency); “Plan a new trip” card.
- **New:** Form with name, **city_id** dropdown (from `City.order(:name)`), start/end date, travelers_count, currency hidden USD. On submit, `apply_city_from_params` sets `destination_city` and `destination_country` from selected city. Create → redirect to `wizard_step_2_trip_path(@trip)`.
- **Create callback:** `after_create :create_default_preference`, `after_create :add_owner_as_participant`, `before_save :set_image_url` (Unsplash search by destination_city).
- **Wizard step 2:** Form for trip_preference (lodging_style, hotel_nights, airbnb_nights, meal counts, activities_count, nightlife_nights, shopping_budget_level, overall_comfort_level, notes). PATCH `wizard_update_preferences_trip_path` → updates preference, runs `BudgetGenerator.new(@trip).call`, redirect to trip show.
- **Show:** Loads trip_budget, trip_preference, expenses (spent_at desc), new Expense for form. Tabs: Overview, Budget & Preferences, Collaborators. Header: destination, dates, nights, travelers, Edit Trip, Recalculate Budget, estimated total and per-person (display currency).
- **Edit:** Same city dropdown, name, dates, travelers_count, currency. On update, if trip_budget exists, runs BudgetGenerator again. Danger Zone: Delete Trip.
- **Generate budget:** POST `generate_budget_trip_path` → BudgetGenerator → redirect with notice.

### 7.3 Budget Generation

- **BudgetGenerator:** Uses `PricingProvider.for(city: destination_city, country:, start_date:, end_date:)`.
- **PricingProvider:**  
  1) Tries `PricingProvider::Snapshot` (City by name → latest `traveltables` snapshot, else latest `estimated`).  
  2) If no snapshot and city in DB, calls `ensure_estimated_snapshot` (Create mock via `CostOfLiving::GenerateMockSnapshot` if no recent estimated snapshot within 30 days).  
  3) Fallback `PricingProvider::Static` (hardcoded defaults).
- **Snapshot#prices:** Reads `snapshot.data`; derives nightly lodging (hotel/airbnb from rent), restaurant/street_food, activity, drinks, shopping, other; returns hash of keys expected by BudgetGenerator (lodging_budget/midrange/premium, restaurant_*, street_food, activity_*, drinks, shopping, other).
- **BudgetGenerator:** Computes lodging (hotel_nights + airbnb_nights × tier price × travelers), food (meal counts × travelers), activities, nightlife (nights × 3 drinks × travelers), shopping (multiplier by level), other (buffer); writes trip_budget scalar columns.

### 7.4 Expenses

- **Create:** From trip show (Overview tab) or from Ledger (link to trip). Params: category, amount, spent_at, description, payer_participant_id (optional). Redirect to trip show with notice.
- **Destroy:** From trip show or Ledger; turbo_confirm “Are you sure?”.
- **Ledger (expenses#index):** Trip filter (GET trip_id); selected trip’s expenses; summary cards (Total Spent, Planned Budget, Remaining); table with Delete; “Add Expense” links to trip.

### 7.5 Trip Preferences (Live Update)

- **Budget tab:** Form with `data: { turbo_stream: true }` PATCH to `trip_preference_path(trip)`. TripPreferencesController#update: updates preference, runs BudgetGenerator, responds with `format.turbo_stream` → `update.turbo_stream.erb` **replaces** `#budget_breakdown` with updated `_budget_breakdown` partial.
- **DOM:** `_budget_tab.html.erb` wraps the breakdown in `<div id="budget_breakdown">`, so Turbo Stream replace works when form is submitted via Turbo.

### 7.6 Cities and Pricing Data

- **Cities:** Slug-based route `cities/:slug`. CitiesController#show: `CitySnapshotPicker.call(@city)` (latest traveltables else latest estimated), `CityCostPresenter.call(@snapshot)` for rows; badge “Real data” / “Estimated”; currency label (display_currency if set).
- **Featured city snapshots:** Query `FeaturedCitySnapshots` (DISTINCT ON city_id, prefer traveltables, order collected_at desc, limit 10); rendered as `_snapshot_card` on trips index; card shows city image, name, country, cost rows from CityCostPresenter.rows_for_card, currency and “Real data”/“Estimated”, updated date.
- **Cost-of-living pipeline:** Rake `cost_of_living:preload_initial_snapshots` — for cities with no snapshots (max 10 per run), calls `CostOfLiving::UpdateCitySnapshot` (fetch → NormalizeTravelTables → create snapshot + items); 1s sleep between cities; on 429 exits with message.
- **Mock snapshot:** `CostOfLiving::GenerateMockSnapshot` — creates snapshot with `source: "estimated"` and `data` keys matching PricingProvider::Snapshot (stay_rent_*, food_cheap_meal, food_mid_meal, drinks_beer, coffee); deterministic from city name length.

### 7.7 Multi-Currency and FX

- **User:** `display_currency` (default USD); editable on registration edit.
- **Helper:** `format_in_display_currency(amount, trip_currency)` — if user has display_currency and it differs from trip, uses `FxRates.convert(amount, trip_currency, display_currency)` and `currency_symbol(display_currency)`; else `number_to_currency(amount)`.
- **FxRates:** Static hash `RATES_TO_USD` (USD 1, EUR 0.92, GBP 0.79, BRL 5.0); `get_rate(from, to)` and `convert(amount, from, to)`; no external API.

### 7.8 Friends & Billing

- **Index:** Trip filter; for selected trip: `@participants = trip_participants`, `@expenses`; `calculate_balances` (equal split: share = total_spent / count; per participant: paid = expenses where payer_participant_id, balance = paid - share); `calculate_settlements` (greedy: creditors/debtors, from/to/amount list).
- **Participants:** Shown on trip Collaborators tab; owner + trip_participants; “Invite Friend” disabled (Coming soon). Trip creator is auto-added as participant on create.

### 7.9 AI Budget Explainer

- **AiBudgetExplainer.explain(trip, budget):** Stub; returns fake string based on per_person_cost (e.g. “higher side” vs “efficient budget”). TODO: OpenAI integration. Rendered in `_budget_breakdown` in a teal info box.

### 7.10 Other

- **PriceEstimator:** Service with static BASE_RATES; not used by main flow (BudgetGenerator uses PricingProvider).
- **PWA:** `manifest.json.erb`, `service-worker.js` under `views/pwa`; layout links manifest and icons.

---

## 8. Routes Summary

| Method | Path | Controller#action |
|--------|------|-------------------|
| GET | / | pages#home |
| (Devise) | /users/sign_in, sign_up, etc. | devise/sessions, registrations |
| Resources | /trips | trips (index, show, new, create, edit, update, destroy) |
| GET | /trips/:id/wizard_step_2 | trips#wizard_step_2 |
| PATCH | /trips/:id/wizard_update_preferences | trips#wizard_update_preferences |
| POST | /trips/:id/generate_budget | trips#generate_budget |
| Resource | /trips/:id/preference | trip_preferences (edit, update) |
| Nested | /trips/:id/expenses | expenses (create, destroy) |
| GET | /cities/:slug | cities#show |
| GET | /ledger | expenses#index |
| GET | /friends | friends#index |
| (Auth) | /sidekiq | Sidekiq::Web |

---

## 9. Design and Layout Summary (Recap)

- **Landing:** Fixed yellow navbar, hero with headline + mockups, “How it works” (3 steps), footer; View Demo → sign-in; Start Planning → sign up.
- **App:** Fixed 64-wide sidebar (Trips, Ledger, Friends & Billing, profile link), sticky topbar (title, search, theme toggle, notifications, log out), main content with flash and yield; all pages use design tokens and support dark mode.
- **Theme:** Brand yellow/charcoal/teal; Satoshi/system font; Tailwind + custom components; dark mode via `.dark` on html and Stimulus theme controller with localStorage.

---

## 10. Known Gaps and PRD Alignment (Concise)

- **Destination:** New/Edit use **city dropdown** and `apply_city_from_params`; trip stores `destination_city`/`destination_country` (no `city_id` on trips). Pricing lookup by city name/country; works when city is in DB.
- **Mock vs Snapshot keys:** `GenerateMockSnapshot` uses keys aligned with `PricingProvider::Snapshot` (stay_rent_*, food_cheap_meal, food_mid_meal, drinks_beer, coffee); Snapshot derives full price hash from these.
- **FriendsController:** Uses `payer_participant_id` correctly for balances.
- **Trip creator as participant:** Implemented in `Trip#add_owner_as_participant`.
- **Live budget update:** Implemented: `#budget_breakdown` in budget tab, Turbo Stream replace on preference update.
- **Expense payer:** Optional; field in overview form when participants exist; `expense_params` includes `payer_participant_id`.
- **Shopping level:** Enum includes `luxury`; wizard form offers low/medium/high/luxury.
- **PriceEstimator / TripBudgetItem / TripPreferenceItem:** Unused in v1; AiBudgetExplainer stub only.

This document is the **full audit and report** of the Billi codebase: purpose, stack, connections, landing and app design/layout, theme, and every detailed functionality covered.
