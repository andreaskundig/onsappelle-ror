class UserMailer < ApplicationMailer
  default from: ENV['MAILER_EMAIL']

  def request_reminder_confirmation_email
    @email = params[:email]
    @reminder = params[:reminder]
    @passwordless_link = params[:passwordless_link]
    @date = @reminder.date.strftime('%Y-%m-%d')
    if @email
      mail(to: @email,
           subject:t('.subject', date: @date))
    end
  end

  def confirm_reminder_email
    @email = params[:email]
    @reminder = params[:reminder]
    @passwordless_link = params[:passwordless_link]
    @date = @reminder.date.strftime('%Y-%m-%d')
    if @email
      mail(to: @email,
           subject:t('.subject', date: @date))
    end
  end

  def remind_email
    @email = params[:email]
    @reminder = params[:reminder]
    recipients = @reminder.users.map {|u| u.email }
    if @email
      mail(to: @email,
           reply_to: recipients,
           subject: "Time to keep in touch")
    end
  end

end
