class ContactMailer < ApplicationMailer
  default from: 'noreply@julianportfolio.com'

  def new_contact(contact_params)
    @name = contact_params[:name]
    @email = contact_params[:email]
    @subject = contact_params[:subject]
    @message = contact_params[:message]

    mail(
      to: 'juliankick@gmail.com',
      subject: "Portfolio Contact: #{@subject}",
      reply_to: @email
    )
  end
end
