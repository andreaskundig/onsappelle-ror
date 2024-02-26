class PasswordlessMailer < ActionMailer::Base

  # adds params[:locale] to every url_for, link_to etc...
  def default_url_options
    Rails.application.config.action_mailer.default_url_options.merge(
      locale: I18n.locale
    )
  end
end
