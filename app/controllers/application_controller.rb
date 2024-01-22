class ApplicationController < ActionController::Base
  include Passwordless::ControllerHelpers

  helper_method :current_user

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    logger.info("HELLO, USER #{current_user&.email}")
    return if current_user
    # so that the user is redirected to where they wanted to go
    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path, flash: { error: 'You are not worthy!' }
  end
end
