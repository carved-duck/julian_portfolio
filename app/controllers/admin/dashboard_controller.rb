module Admin
  class DashboardController < Admin::BaseController
    def index
      # Simple dashboard with counts for each model
      @projects_count = Project.count
      @photos_count = Photo.count
      @blog_posts_count = BlogPost.count
      @events_count = Event.count
      @total_attendees = Attendee.count

      # Enhanced visitor analytics
      @visitor_count = ApplicationController.visitor_count
      @total_page_views = ApplicationController.total_page_views
      @recent_visitors = ApplicationController.recent_visitors.first(10)
      @popular_pages = ApplicationController.popular_pages

      # Calculate some additional metrics
      @avg_pages_per_visitor = @visitor_count.positive? ? (@total_page_views.to_f / @visitor_count).round(2) : 0
      @visitors_today = count_visitors_today
    end

    private

    def count_visitors_today
      today_start = Time.current.beginning_of_day
      ApplicationController.recent_visitors.count do |visitor|
        Time.parse(visitor[:timestamp]) >= today_start
      end
    rescue StandardError
      0
    end
  end
end
