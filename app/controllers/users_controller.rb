class UsersController < ApplicationController
  include ReminderFactory
  include UsersHelper

  # it might be better to have this in the parent
  # but then it affects the default sign_in route
  # and it's not clear where skip_before_action
  # could be set
  before_action :require_user!
  skip_before_action :require_user!, only: [:new_inputs]

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

  # TODO delete if not used...
  def create
    @reminder = Reminder.find(params[:reminder_id])
    @user = @reminder.users.build(user_params)
    # email = params[:user][:email]
    # update_reminder_recipients(@reminder, [email])
    # TODO check if users were removed or added
    # TODO send confirmation email
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
