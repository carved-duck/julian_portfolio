require "test_helper"

module Admin
  class AttendeeRemovalTest < ActionDispatch::IntegrationTest
    setup do
      @saved_env = ENV.to_h.slice("ADMIN_USERNAME", "ADMIN_PASSWORD")
      ENV["ADMIN_USERNAME"] = "admin"
      ENV["ADMIN_PASSWORD"] = "secret"
      @auth = { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("admin", "secret") }

      @event = Event.create!(title: "BBQ", description: "Grill", event_type: "bbq", active: true)
      @guests = %w[Ana Ben Cleo].map { |name| @event.attendees.create!(name: name, instagram_handle: "@#{name}") }
      @other_event = Event.create!(title: "Other BBQ", description: "Grill", event_type: "bbq", active: true)
      @outsider = @other_event.attendees.create!(name: "Dee", instagram_handle: "@dee")
    end

    teardown do
      %w[ADMIN_USERNAME ADMIN_PASSWORD].each { |key| ENV[key] = @saved_env[key] }
    end

    test "remove all clears the guest list and keeps the event" do
      delete remove_all_admin_event_attendees_url(@event), headers: @auth

      assert_redirected_to admin_event_url(@event)
      assert_equal 0, @event.attendees.count
      assert Event.exists?(@event.id)
      assert Attendee.exists?(@outsider.id)
    end

    test "remove selected removes only the ticked attendees of this event" do
      delete remove_selected_admin_event_attendees_url(@event),
             params: { attendee_ids: [@guests.first.id, @outsider.id] }, headers: @auth

      assert_equal %w[Ben Cleo], @event.attendees.order(:name).pluck(:name)
      assert Attendee.exists?(@outsider.id), "an id from another event must be ignored"
    end

    test "remove selected with nothing ticked removes nobody" do
      delete remove_selected_admin_event_attendees_url(@event), headers: @auth

      assert_equal 3, @event.attendees.count
      assert_match(/Tick at least one/, flash[:notice])
    end

    test "every delete on the event page asks first" do
      get admin_event_url(@event), headers: @auth

      assert_select "form[action=?][data-turbo-confirm]", admin_event_path(@event)
      assert_select "form[action=?][data-turbo-confirm]", remove_all_admin_event_attendees_path(@event)
      assert_select "form[action=?][data-turbo-confirm]", remove_selected_admin_event_attendees_path(@event)
      assert_select "[data-confirm]", false, "data-confirm needs rails-ujs, which this app doesn't load"
    end

    test "a guest list of one says 'the 1 attendee', not 'all 1 attendee'" do
      solo = Event.create!(title: "Solo", description: "Just one", event_type: "bbq", active: true)
      solo.attendees.create!(name: "Eve", instagram_handle: "@eve")

      get admin_event_url(solo), headers: @auth

      assert_select "form[action=?] button", "Remove the 1 attendee", remove_all_admin_event_attendees_path(solo)
    end

    test "the bringing summary lists what people bring, escaped" do
      potluck = Event.create!(title: "Potluck", description: "Dishes", event_type: "normal",
                              active: true, enable_bringing_categories: true)
      potluck.attendees.create!(name: "Fay", instagram_handle: "@fay", bringing: "Drinks")
      potluck.attendees.create!(name: "Gus", instagram_handle: "@gus", bringing: "Other", bringing_other: "<b>x</b>")

      get admin_event_url(potluck), headers: @auth

      assert_select "p", /Drinks: 1 person/
      assert_includes response.body, "&lt;b&gt;x&lt;/b&gt;"
      assert_not_includes response.body, "<b>x</b>"
    end

    test "removal needs the admin login" do
      delete remove_all_admin_event_attendees_url(@event)

      assert_response :unauthorized
      assert_equal 3, @event.attendees.count
    end
  end
end
