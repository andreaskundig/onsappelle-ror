class UsersController < ApplicationController
  include ReminderFactory

  def index
    @reminder = Reminder.find(params[:reminder_id])
  end

  def show
    @reminder = Reminder.find(params[:reminder_id])
    @user = User.find(params[:id])
  end

  def new
    @reminder = Reminder.find(params[:reminder_id])
    # @user = @reminder.users.build
  end

  def create
    @reminder = Reminder.find(params[:reminder_id])
    email = params[:user][:email]
    add_reminder_recipients(@reminder, [email])
    @reminder.save
    redirect_to reminder_path(@reminder)
  end

  private
    def user_params
      params.require(:user).permit(:email)
    end

end
