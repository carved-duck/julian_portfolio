class PagesController < ApplicationController
  def home
    @projects = Project.all
  end

    def contact
    # Honeypot spam protection - if 'website' field is filled, it's a bot
    if params[:website].present?
      render json: { status: 'error', message: 'Spam detected.' }
      return
    end

    contact_params = params.permit(:name, :email, :subject, :message)

    # Send email using ActionMailer
    ContactMailer.new_contact(contact_params).deliver_now

    render json: { status: 'success', message: 'Message sent successfully! I\'ll get back to you soon.' }
  rescue => e
    render json: { status: 'error', message: 'Failed to send message. Please try again.' }
  end
end
