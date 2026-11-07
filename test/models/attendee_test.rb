require "test_helper"

class AttendeeTest < ActiveSupport::TestCase
  setup do
    @event = Event.create!(title: "Potluck", description: "Bring a dish", event_type: "normal",
                           active: true, enable_bringing_categories: true)
  end

  test "Other with nothing typed is rejected instead of saving the word Other" do
    attendee = @event.attendees.build(name: "Luigi", instagram_handle: "@luigi", bringing: "Other")

    assert_not attendee.valid?
    assert attendee.errors[:bringing_other].any?
  end

  test "Other saves what the visitor typed" do
    attendee = @event.attendees.create!(name: "Luigi", instagram_handle: "@luigi",
                                        bringing: "Other", bringing_other: " Lasagna ")

    assert_equal "Lasagna", attendee.reload.bringing
  end
end
