module Admin
  module AttendeesHelper
    # How to name a whole guest list in buttons, confirms and notices: "all 30 attendees",
    # but "the 1 attendee" rather than "all 1 attendee".
    def whole_guest_list(count)
      count == 1 ? "the 1 attendee" : "all #{count} attendees"
    end
  end
end
