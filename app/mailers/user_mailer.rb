class UserMailer < ApplicationMailer
  default from: ENV['MAILER_EMAIL']

  def ask_reminder_confirmation_email
    @email = params[:email]
    @reminder = params[:reminder]
    @passwordless_link = params[:passwordless_link]
    formatted_date = @reminder.date.strftime('%Y-%m-%d')
    if @email
      mail(to: @email,
           subject: "Confirm reminder at #{formatted_date}")
    end
  end

  def confirm_reminder_email
    @email = params[:email]
    @reminder = params[:reminder]
    @passwordless_link = params[:passwordless_link]
    formatted_date = @reminder.date.strftime('%Y-%m-%d')
    if @email
      mail(to: @email,
           subject: "Reminder at #{formatted_date}")
    end
  end

end
