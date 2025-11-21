# Billi - AI Travel Budget Planner

Billi is a production-ready MVP for travel budget planning. It helps users estimate travel costs based on real average prices and their personal preferences.

## Features

- **Trip Wizard**: Multi-step flow to define destination, dates, and preferences.
- **Budget Engine**: Calculates per-person budgets using average prices for specific cities and seasons.
- **Live Recalculation**: Adjust preferences (e.g., hotel vs. Airbnb, number of fancy meals) and see the budget update instantly.
- **Expense Tracking**: Log actual expenses and compare them against the planned budget.
- **AI Integration**: Placeholder for AI-driven budget explanations.

## Tech Stack

- **Backend**: Ruby on Rails 7.2 + PostgreSQL
- **Frontend**: Tailwind CSS, Hotwire (Turbo + Stimulus)
- **Auth**: Devise
- **Jobs**: Sidekiq + Redis
- **Testing**: RSpec + FactoryBot

## Setup

1. **Prerequisites**:
   - Ruby 3.x
   - PostgreSQL
   - Redis

2. **Installation**:
   ```bash
   bundle install
   yarn install # or rails assets:precompile logic if needed, though importmap is used.
   ```

3. **Database Setup**:
   ```bash
   rails db:setup
   ```
   *This will create the DB, run migrations, and seed demo data (User: demo@billi.app / password).*

4. **Run Server**:
   ```bash
   bin/dev
   ```
   Visit `http://localhost:3000`.

## Architecture

- **PricingProvider**: Service abstraction for fetching price data. Currently `PricingProvider::Static` uses the `PriceSnapshot` table. `PricingProvider::ExternalApi` can be implemented to fetch from APIs.
- **BudgetGenerator**: Core service that combines Trip Preferences and Price Snapshots to generate `TripBudget`.
- **AiBudgetExplainer**: Service to generate natural language insights (currently mocked).

## License

MIT
