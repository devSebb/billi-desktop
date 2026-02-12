namespace :trip_participants do
  desc "Backfill owner as TripParticipant for trips that don't have one (safe to run multiple times)"
  task backfill_owners: :environment do
    count = 0
    Trip.find_each do |trip|
      next if trip.trip_participants.exists?(user_id: trip.user_id)

      trip.trip_participants.create!(
        user_id: trip.user_id,
        is_user: true,
        name: trip.user.name.presence || trip.user.email
      )
      count += 1
    end
    puts "Created #{count} owner participant(s) for existing trips."
  end
end
