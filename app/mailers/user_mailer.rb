class UserMailer < ApplicationMailer
  default from: ENV['MAILER_EMAIL']

  def added_to_reminder_email
    @emails = params[:emails]
    @reminder = params[:reminder]
    formatted_date = @reminder.date.strftime('%Y-%m-%d')
    if @emails and not @emails.empty?
      mail(to: @emails,
          subject: "Reminder at #{formatted_date}")
    end
  end
end
