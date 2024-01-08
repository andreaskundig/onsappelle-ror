class UserMailer < ApplicationMailer
  default from: ENV['MAILER_EMAIL']

  def added_to_reminder_email
    @user = params[:user]
    @reminder = params[:reminder]
    @url = 'http://example.com/login'
    formatted_date = @reminder.date.strftime('%Y-%m-%d')
    mail(to: @user.email,
         subject: "Reminder at #{formatted_date}")
  end
end
