Passwordless.configure do |config|
  config.parent_mailer = "PasswordlessMailer"
  # config.redirect_to_response_options = {locale: I18n.locale}
  # config.success_redirect_path = "/#{I18n.locale}"
end
