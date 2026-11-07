require "test_helper"

class EventsHelperTest < ActionView::TestCase
  setup do
    @event = Event.create!(title: "Potluck", description: "Bring a dish", event_type: "normal",
                           active: true, enable_bringing_categories: true)
  end

  def sign_up(bringing)
    @event.attendees.create!(name: "Guest", instagram_handle: "@guest", bringing: bringing)
  end

  test "Most needed tags the one dish with the fewest people" do
    (Event::BRINGING_CATEGORIES - ["Main Dish"]).each { |dish| sign_up(dish) }

    needed = bringing_rows(@event).select(&:most_needed).map(&:value)

    assert_equal ["Main Dish"], needed
  end

  test "a tie for fewest tags nothing, so a fresh event isn't covered in tags" do
    assert_empty bringing_rows(@event).select(&:most_needed)
  end

  test "bars scale to the most popular dish" do
    2.times { sign_up("Drinks") }
    sign_up("Snacks")

    bars = bringing_rows(@event).to_h { |row| [row.value, row.bar_percent] }

    assert_equal 100, bars["Drinks"]
    assert_equal 50, bars["Snacks"]
    assert_equal 0, bars["Desserts"]
  end
end
