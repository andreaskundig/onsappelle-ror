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
    @date = @reminder.date.strftime('%d.%m.%Y')
    recipients = @reminder.users.map {|u| u.email }
    locale = @reminder.locale || I18n.default_locale
    I18n.with_locale(locale) do
      if @email
        mail(to: @email,
             reply_to: recipients,
             subject: t('.subject'))
      end
    end
  end

end
