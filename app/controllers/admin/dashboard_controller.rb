class Admin::DashboardController < Admin::BaseController
  def index
    # Simple dashboard with counts for each model
    @projects_count = Project.count
    @photos_count = Photo.count
    @blog_posts_count = BlogPost.count
    @events_count = Event.count
    @total_attendees = Attendee.count
  end
end
