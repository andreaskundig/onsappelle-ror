class RemindersController < ApplicationController
  include ReminderFactory

  def index
    @reminders = Reminder.all
  end

  def show
    @reminder = Reminder.find(params[:id])
  end

  def new
    @reminder = Reminder.new
  end

  def create
    @reminder = Reminder.new(reminder_params)
    email = params[:reminder][:users][:email]
    if email
    then add_reminder_recipients(@reminder, [email]) end

    if @reminder.save # saves to db
      # save has worked
      # makes a new request to end this one
      redirect_to @reminder
    else
      # just renders the view new.html.erb,
      # with an error, and without a new request
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @reminder = Reminder.find(params[:id])
    logger.info("editing #{@reminder}")
  end

  def update
    @reminder = Reminder.find(params[:id])
    email = params[:reminder][:users][:email]
    if email
    then add_reminder_recipients(@reminder, [email]) end

    if @reminder.update(reminder_params)
      redirect_to @reminder
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    redirect_to root_path, status: :see_other
  end

  private
    def reminder_params
      params.require(:reminder).permit(:date, :email)
    end
end
