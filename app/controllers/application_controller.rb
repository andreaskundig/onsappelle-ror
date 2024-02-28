class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers
  around_action :switch_locale
  helper_method :current_user

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    logger.info("HELLO, USER #{current_user&.email}")
    return if current_user
    notice = 'You are not worthy!'
    # if controller_name == 'reminders' and action_name == 'confirm'
    #   notice = "Confirm the reminder by clicking on the link in the email you will receive."
    # end
    # so that the user is redirected to where they wanted to go
    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path, flash: { notice: notice }
  end

  # https://guides.rubyonrails.org/i18n.html#managing-the-locale-across-requests
  # so that locale is set before rendering templates
  # and the link_to and url_to point to the correct locale
  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  # adds params[:locale] to every url_for, link_to etc...
  # https://guides.rubyonrails.org/i18n.html#setting-the-locale-from-url-params
  def default_url_options
    Rails.application.routes.default_url_options.merge(
      locale: I18n.locale
    )
  end
end

