class Event < ApplicationRecord
  has_many :attendees, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true

  scope :active, -> { where(active: true) }

  def attendee_count
    attendees.count
  end

  # Capacity management for BBQ table limits (10/20/30 people per table)
    def next_table_threshold
    return nil unless target_capacity.present?

    current_count = attendee_count
    # Find next multiple of 10 that's >= current count
    ((current_count / 10.0).ceil * 10)
  end

      def in_pending_zone?
    return false unless target_capacity.present?

    current_count = attendee_count

    # Don't warn if we haven't even reached the first table yet
    return false if current_count <= 10

    # Don't warn if we're beyond what we're targeting
    return false if current_count > target_capacity

    # Find which table "zone" we're in
    current_table = ((current_count - 1) / 10) + 1  # Which table number we're filling
    base_for_current_table = (current_table - 1) * 10  # 0, 10, 20, 30...
    next_table_starts_at = current_table * 10  # 10, 20, 30, 40...

    # We're in pending if we're over a table boundary but not close to the next one
    # Example: 11-17 people (over 10, but not close to 20), 21-27 people (over 20, not close to 30)
    people_over_boundary = current_count - base_for_current_table
    people_until_next_table = next_table_starts_at - current_count

    # Pending if we're 1-7 people over a table boundary (leaving 3+ spots until next table)
    people_over_boundary > 0 && people_until_next_table >= 3
  end

  def capacity_warning_message
    return nil unless in_pending_zone?

    current_count = attendee_count
    current_table = ((current_count - 1) / 10) + 1
    next_table_starts_at = current_table * 10
    people_until_next_table = next_table_starts_at - current_count

    "⚠️ You're over the #{current_table == 1 ? '1st' : current_table == 2 ? '2nd' : current_table == 3 ? '3rd' : "#{current_table}th"} table limit (#{(current_table - 1) * 10} people). " \
    "You'll be on a pending list until we get #{people_until_next_table} more #{people_until_next_table == 1 ? 'person' : 'people'} to fill the #{current_table + 1 == 2 ? '2nd' : current_table + 1 == 3 ? '3rd' : "#{current_table + 1}th"} table (#{next_table_starts_at} people total)."
  end

  def spots_until_next_table
    return nil unless target_capacity.present?
    next_table_threshold - attendee_count
  end
end
