class UsersController < ApplicationController
  include ReminderFactory
  include UsersHelper

  def index
    @reminder = Reminder.find(params[:reminder_id])
  end

  def show
    @reminder = Reminder.find(params[:reminder_id])
    @user = User.find(params[:id])
  end

  def new_inputs
    email = params[:user][:email]
    @user = User.find_by(email: email)
    @email_code = email_to_code(email)
    unless @user
      @user = User.new(user_params)
      @user.validate
    end
    respond_to :turbo_stream
  end

  def remove_inputs
    @email_code = params[:email_code]
    respond_to :turbo_stream
  end

  def new
    @reminder = Reminder.find(params[:reminder_id])
    # @user = @reminder.users.build
  end

  def create
    @reminder = Reminder.find(params[:reminder_id])
    @user = @reminder.users.build(user_params)
    # email = params[:user][:email]
    # add_reminder_recipients(@reminder, [email])
    if @reminder.save
      respond_to do |format|
        format.html { redirect_to reminder_path(@reminder) }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.require(:user).permit(:email)
    end
end
