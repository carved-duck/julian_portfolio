require "test_helper"

class AttendeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event = Event.create!(title: "Potluck", description: "Bring a dish", event_type: "normal",
                           active: true, enable_bringing_categories: true)
  end

  test "a rejected signup keeps what the visitor typed and shows the field error" do
    post event_attendees_url(@event),
         params: { attendee: { name: "Luigi", instagram_handle: "@luigi", bringing: "", message: "a pie" } }

    assert_response :unprocessable_entity
    assert_select "#attendee_name[value=?]", "Luigi"
    assert_select "#attendee_instagram_handle[value=?]", "@luigi"
    assert_select ".attendee_bringing .invalid-feedback"
  end

  test "a rejected Other signup keeps Other selected and its text" do
    post event_attendees_url(@event),
         params: { attendee: { name: "", instagram_handle: "@luigi", bringing: "Other", bringing_other: "Lasagna" } }

    assert_response :unprocessable_entity
    assert_select "#attendee_bringing option[selected][value=?]", "Other"
    assert_select "#attendee_bringing_other[value=?]", "Lasagna"
  end

  test "Not sure yet is a valid answer and the thanks doesn't claim a dish" do
    post event_attendees_url(@event),
         params: { attendee: { name: "Luigi", instagram_handle: "@luigi", bringing: "Not sure yet" } }

    assert_redirected_to events_url
    assert_equal "Not sure yet", @event.attendees.last.bringing
    assert_no_match(/Thanks for bringing/, flash[:notice])
  end
end
