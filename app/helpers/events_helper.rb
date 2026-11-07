module EventsHelper
  BringingRow = Struct.new(:value, :count_text, :bar_percent, :most_needed, keyword_init: true)

  # One row per food category for the signup form's "sign-up sheet": how many people are already
  # bringing it, a bar scaled to the most popular dish, and "Most needed" on the single dish with
  # the fewest people (no tag on a tie, so a fresh event doesn't tag everything).
  def bringing_rows(event)
    breakdown = event.bringing_breakdown
    counts = Event::BRINGING_CATEGORIES.index_with { |category| breakdown[category].to_i }
    most = counts.values.max
    needed = most_needed_dish(counts)

    counts.map do |category, count|
      BringingRow.new(value: category,
                      count_text: bringing_count_text(count),
                      bar_percent: most.zero? ? 0 : (count * 100 / most),
                      most_needed: category == needed)
    end
  end

  private

  def most_needed_dish(counts)
    fewest = counts.values.min
    counts.key(fewest) if counts.values.count(fewest) == 1
  end

  def bringing_count_text(count)
    return 'Nobody yet' if count.zero?

    "#{pluralize(count, 'person', plural: 'people')} bringing"
  end
end
