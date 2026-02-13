# Cost of Living Data in Production

## Where the data lives

- **Cities** (names, countries, slugs) come from **seeds** and live in the `cities` table. They are created by `rails db:seed` (or `db:setup`).
- **Price data** is **not** in the repo and **not** from a build step. It is stored in the **database**:
  - **`price_snapshots`** – one row per fetch: `city_id`, `source` (`traveltables` or `estimated`), `currency`, jsonb `data`, `collected_at`.
  - **`price_snapshot_items`** – normalized rows per category for each snapshot.

The app always uses the **most recent** snapshot per city (see `CitySnapshotPicker`, `PricingProvider::Snapshot`). So “latest info” = run the fetch task and new rows are created; the app will use them automatically.

## How it’s fetched

- **Service:** `CostOfLiving::UpdateCitySnapshot` calls the TravelTables API (RapidAPI) for a city and creates one `PriceSnapshot` + items.
- **Rake tasks:** `lib/tasks/cost_of_living.rake`:
  - **`cost_of_living:preload_initial_snapshots`** – only cities that have **no** snapshots (max 10 per run, 1s delay, stops on 429).
  - **`cost_of_living:refresh_snapshots`** – can refresh **all** cities (or a limit) to get the latest API data; same rate-limit handling.

So: **populating or refreshing city info in production = running one of these rake tasks against the production app**, not a build or pre-build command.

## Populating empty production (e.g. after deploy or new DB)

1. **Seeds**  
   Ensure cities exist. If the DB was created with `db:setup` or you run `db:seed`, the 50 cities from `db/seeds.rb` are already there.

2. **API key in production**  
   Set in the production environment (e.g. Render env vars or Rails credentials):
   - `RAPIDAPI_COST_LIVING_KEY` (required)
   - Optionally: `RAPIDAPI_COST_LIVING_HOST` (default: `cost-of-living-and-prices.p.rapidapi.com`)

3. **Run the preload task on production**  
   From a **one-off shell** on your host (e.g. Render “Shell” or `rails console`), run:
   ```bash
   bundle exec rails cost_of_living:preload_initial_snapshots
   ```
   - It processes up to **10 cities per run** and respects the API rate limit (often 10 req/hour on free tier).
   - Run it **once per hour** until all cities have at least one snapshot, or use the refresh task with a limit (see below).

4. **Optional: get latest data for all cities**  
   If you want to refresh every city with the newest API data:
   ```bash
   bundle exec rails cost_of_living:refresh_snapshots
   ```
   Or with a limit (e.g. 5 cities per run for strict rate limits):
   ```bash   LIMIT=5 bundle exec rails cost_of_living:refresh_snapshots
   ```

## Not a build command

- Populating/refreshing city data is **not** part of the app **build** (no pre-build or post-build step in the codebase).
- It’s a **runtime** operation: run the rake task when you need to fill or update data (manually, cron, or a release script if you add one).

## Optional: run on deploy (e.g. Render)

If you want to preload a few cities on every deploy (e.g. only those still missing data), you can add a **release command** that runs the preload task:

- **Render:** In the service settings, set **Release Command** to something like:
  ```bash
  bundle exec rails db:migrate && bundle exec rails cost_of_living:preload_initial_snapshots
  ```
  That way each deploy runs migrations and then fetches up to 10 cities that still have no snapshot. With a 10/hour limit, full preload will still take multiple deploys or manual runs.

Alternatively, run the task on a schedule (cron) or via a background job instead of in the release command.
