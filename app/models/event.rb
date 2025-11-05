class Event < ApplicationRecord
  has_many :attendees, dependent: :destroy

  validates :title, presence: true
  validates :description, presence: true
  validates :event_type, presence: true, inclusion: { in: %w[bbq normal] }

  scope :active, -> { where(active: true) }
  scope :bbq_events, -> { where(event_type: 'bbq') }
  scope :normal_events, -> { where(event_type: 'normal') }

  def bbq_event?
    event_type == 'bbq'
  end

  def normal_event?
    event_type == 'normal'
  end

  def requires_bringing_field?
    normal_event? && enable_bringing_categories?
  end

  def attendee_count
    attendees.count
  end

  # Capacity management for BBQ table limits (10/20/30 people per table)
  def next_table_threshold
    return nil unless target_capacity.present? && bbq_event?

    current_count = attendee_count
    # Find next multiple of 10 that's >= current count
    ((current_count / 10.0).ceil * 10)
  end

  def in_pending_zone?
    # Only BBQ events use pending zone logic
    return false unless bbq_event? && target_capacity.present?

    current_count = attendee_count

    # Don't warn if we haven't even reached the first table yet
    return false if current_count <= 10

    # If we're beyond target capacity, we're always pending (except at exact table boundaries)
    if current_count > target_capacity
      # Always pending if we're beyond target AND not at an exact table boundary
      return current_count % 10 != 0
    end

    # Original logic for within target capacity
    # Find which table "zone" we're in
    current_table = ((current_count - 1) / 10) + 1 # Which table number we're filling
    base_for_current_table = (current_table - 1) * 10 # 0, 10, 20, 30...
    next_table_starts_at = current_table * 10 # 10, 20, 30, 40...

    # We're in pending if we're over a table boundary but not close to the next one
    # Example: 11-17 people (over 10, but not close to 20), 21-27 people (over 20, not close to 30)
    people_over_boundary = current_count - base_for_current_table
    people_until_next_table = next_table_starts_at - current_count

    # Pending if we're 1-7 people over a table boundary (leaving 3+ spots until next table)
    people_over_boundary.positive? && people_until_next_table >= 3
  end

  # Normal events: simple capacity check
  def at_capacity?
    return false unless target_capacity.present?

    if normal_event?
      attendee_count >= target_capacity
    else
      false # BBQ events use pending zone logic instead
    end
  end

  def capacity_full_message
    return nil unless normal_event? && at_capacity?

    "This event is full! Please contact @jju.irl on Instagram or julian@trendrider.io if you'd like to be added to a waitlist."
  end

  def capacity_warning_message
    return nil unless in_pending_zone?

    current_count = attendee_count
    current_table = ((current_count - 1) / 10) + 1  # Which table we're filling
    exceeded_table = current_table - 1              # Which table limit we exceeded
    next_table_starts_at = current_table * 10
    people_until_next_table = next_table_starts_at - current_count

    # Different message if we're beyond target capacity
    if current_count > target_capacity
      "⚠️ This event is beyond its target capacity of #{target_capacity} people. " \
        "You're over the #{case exceeded_table
                           when 1
                             '1st'
                           when 2
                             '2nd'
                           else
                             exceeded_table == 3 ? '3rd' : "#{exceeded_table}th"
                           end} table limit (#{exceeded_table * 10} people). " \
      "You'll be on a pending list until we get #{people_until_next_table} more #{people_until_next_table == 1 ? 'person' : 'people'} to fill the #{if current_table == 2
                                                                                                                                                      '2nd'
                                                                                                                                                    else
                                                                                                                                                      current_table == 3 ? '3rd' : "#{current_table}th"
                                                                                                                                                    end} table (#{next_table_starts_at} people total)."
    else
      # Original message for within target capacity
      "⚠️ You're over the #{case exceeded_table
                            when 1
                              '1st'
                            when 2
                              '2nd'
                            else
                              exceeded_table == 3 ? '3rd' : "#{exceeded_table}th"
                            end} table limit (#{exceeded_table * 10} people). " \
        "You'll be on a pending list until we get #{people_until_next_table} more #{people_until_next_table == 1 ? 'person' : 'people'} to fill the #{if current_table == 2
                                                                                                                                                        '2nd'
                                                                                                                                                      else
                                                                                                                                                        current_table == 3 ? '3rd' : "#{current_table}th"
                                                                                                                                                      end} table (#{next_table_starts_at} people total)."
    end
  end

  def spots_until_next_table
    return nil unless target_capacity.present? && bbq_event?

    next_table_threshold - attendee_count
  end

  # For normal events with bringing categories enabled, get bringing breakdown
  def bringing_breakdown
    return {} unless requires_bringing_field?

    breakdown = attendees.group(:bringing).count
    # Ensure all categories are represented
    BRINGING_CATEGORIES.each do |category|
      breakdown[category] ||= 0
    end
    breakdown
  end

  BRINGING_CATEGORIES = [
    'Drinks',
    'Desserts',
    'Snacks',
    'Appetizers',
    'Main Dish'
  ].freeze
end
