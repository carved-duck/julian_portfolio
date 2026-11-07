module EventsHelper
  # Options for the signup form's "What will you be bringing?" dropdown, as [label, value] pairs.
  # Food categories show how many people already picked them, so the potluck balances itself.
  def bringing_options(event)
    breakdown = event.bringing_breakdown
    categories = Event::BRINGING_CATEGORIES.map do |category|
      count = breakdown[category].to_i
      label = count.positive? ? "#{category} (#{pluralize(count, 'person', plural: 'people')})" : category
      [label, category]
    end

    categories + [[Attendee::BRINGING_NOT_SURE, Attendee::BRINGING_NOT_SURE],
                  ['Other (specify below)', Attendee::BRINGING_OTHER]]
  end
end
