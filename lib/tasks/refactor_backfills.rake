namespace :refactor do
  desc "Backfill data for database refactoring"
  task backfill: :environment do
    puts "Starting Backfill..."

    ActiveRecord::Base.transaction do
      # 1. TripParticipants
      puts "Backfilling TripParticipants..."
      TripParticipant.where.not(user_id: nil).find_each do |tp|
        # Clear name/email for registered users as per requirement
        tp.update_columns(name: nil, email: nil)
      end

      # 2. Expenses Payer
      puts "Backfilling Expenses Payer..."
      Expense.where(payer_participant_id: nil).where.not(payer_id: nil).find_each do |expense|
        # Check if payer_id is already a TripParticipant ID
        if TripParticipant.exists?(expense.payer_id)
          expense.update_column(:payer_participant_id, expense.payer_id)
        else
          # Assume payer_id might be a User ID (legacy data scenario)
          participant = TripParticipant.find_by(trip_id: expense.trip_id, user_id: expense.payer_id)
          if participant
            expense.update_column(:payer_participant_id, participant.id)
          else
            puts "WARNING: Could not map payer_id #{expense.payer_id} for Expense #{expense.id}"
          end
        end
      end

      # 3. PriceSnapshots
      puts "Backfilling PriceSnapshots..."
      PriceSnapshot.find_each do |snapshot|
        next if snapshot.data.blank?
        
        snapshot.data.each do |category, amount|
          # Attempt to parse amount
          amount_val = amount.to_f rescue 0.0
          next if amount_val <= 0

          PriceSnapshotItem.create!(
            price_snapshot_id: snapshot.id,
            city_id: snapshot.city_id,
            category: category.to_s,
            amount: amount_val,
            currency: snapshot.currency,
            source: snapshot.source,
            collected_at: snapshot.collected_at || snapshot.created_at
          )
        end
      end

      # 4. TripBudgets
      puts "Backfilling TripBudgets..."
      columns_map = {
        'lodging_total' => 'lodging',
        'restaurants_total' => 'restaurants',
        'activities_total' => 'activities',
        'drinks_total' => 'drinks',
        'shopping_total' => 'shopping',
        'other_total' => 'other'
      }
      
      TripBudget.find_each do |budget|
        columns_map.each do |col, cat|
          val = budget.public_send(col)
          if val && val > 0
            TripBudgetItem.create!(
              trip_budget_id: budget.id,
              trip_id: budget.trip_id,
              category: cat,
              amount: val,
              currency: budget.currency
            )
          end
        end
      end

      # 5. TripPreferences
      puts "Backfilling TripPreferences..."
      pref_columns = [
        'hotel_nights', 'airbnb_nights', 'fancy_restaurant_meals', 
        'casual_restaurant_meals', 'street_food_meals', 'activities_count', 
        'nightlife_nights'
      ]

      TripPreference.find_each do |pref|
        pref_columns.each do |col|
          val = pref.public_send(col)
          if val && val > 0
            TripPreferenceItem.create!(
              trip_preference_id: pref.id,
              trip_id: pref.trip_id,
              category: col, # keeping snake_case name
              value: val,
              unit: col.include?('nights') ? 'nights' : (col.include?('count') ? 'count' : 'meals')
            )
          end
        end
      end
    end

    puts "Backfill completed successfully!"
  end
end

