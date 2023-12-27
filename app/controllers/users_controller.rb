class UsersController < ApplicationController
  def create
    @reminder = Reminder.find(params[:reminder_id])
    email = params[:user][:email].strip
    @user = User.find_by(email: email)
    logger.debug "found user #{@user}"
    unless @user
      logger.debug "we need to create a user for #{params[:email]}"
      @user = @reminder.users.create(user_params)
    end
    redirect_to reminder_path(@reminder)
  end

  private
    def user_params
      params.require(:user).permit(:email)
    end

end
