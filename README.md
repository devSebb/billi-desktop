# Billi - AI Travel Budget Planner

Billi is a production-ready MVP for travel budget planning. It helps users estimate travel costs based on real average prices and their personal preferences.

## Features

- **Trip Wizard**: Multi-step flow to define destination, dates, and preferences.
- **Budget Engine**: Calculates per-person budgets using **real cost-of-living data**.
- **Live Recalculation**: Adjust preferences (e.g., hotel vs. Airbnb, number of fancy meals) and see the budget update instantly.
- **Expense Tracking**: Log actual expenses and compare them against the planned budget.
- **AI Integration**: Placeholder for AI-driven budget explanations.

## Tech Stack

- **Backend**: Ruby on Rails 7.2 + PostgreSQL
- **Frontend**: Tailwind CSS, Hotwire (Turbo + Stimulus)
- **Data Source**: RapidAPI TravelTables (Cost of Living)
- **Auth**: Devise
- **Jobs**: Sidekiq + Redis
- **Testing**: RSpec + FactoryBot

## Setup

1. **Prerequisites**:
   - Ruby 3.x
   - PostgreSQL
   - Redis

2. **Environment Variables**:
   Set the following in `.env` or Rails credentials:
   - `RAPIDAPI_COST_LIVING_KEY`: Your RapidAPI Key
   - `RAPIDAPI_COST_LIVING_HOST`: `cost-of-living-and-prices.p.rapidapi.com`

3. **Installation**:
   ```bash
   bundle install
   ```

4. **Database Setup**:
   ```bash
   rails db:setup
   ```
   *This will create the DB, run migrations, and seed demo data (User: demo@billi.app / password).*

5. **Data Initialization**:
   The app uses real cost data for 50 supported tourism cities. You need to populate the initial snapshots.
   
   **Important**: The API has a limit of 10 requests/hour on the free plan. The preload task handles this by checking for uninitialized cities and fetching up to 10 at a time.
   
   Run this task once per hour until all cities are initialized:
   ```bash
   rails cost_of_living:preload_initial_snapshots
   ```

6. **Run Server**:
   ```bash
   bin/dev
   ```
   Visit `http://localhost:3000`.

## Architecture

- **CostOfLiving Service**: Handles fetching and normalizing data from TravelTables API.
  - `TravelTablesClient`: Raw API client.
  - `NormalizeTravelTables`: Maps API items to internal schema.
  - `UpdateCitySnapshot`: Persists data to `PriceSnapshot`.
- **PricingProvider**: Service abstraction for fetching price data. Now uses `PricingProvider::Snapshot` to read from the `jsonb` data in `PriceSnapshot`.
- **BudgetGenerator**: Core service that combines Trip Preferences and Price Snapshots to generate `TripBudget`.

## License

MIT
