class PagesController < ApplicationController
  def home
    @projects = Project.all
  end

  def contact
    contact_params = params.permit(:name, :email, :subject, :message)

    # Send email using ActionMailer
    ContactMailer.new_contact(contact_params).deliver_now

    render json: { status: 'success', message: 'Message sent successfully!' }
  rescue => e
    render json: { status: 'error', message: 'Failed to send message. Please try again.' }
  end
end
