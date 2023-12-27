class UsersController < ApplicationController
  include ReminderFactory

  def create
    @reminder = Reminder.find(params[:reminder_id])
    email = params[:user][:email]
    add_reminder_recipients(@reminder, [email])
    redirect_to reminder_path(@reminder)
  end

  private
    def user_params
      params.require(:user).permit(:email)
    end

end
