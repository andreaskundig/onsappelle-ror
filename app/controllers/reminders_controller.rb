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
    @reminder.users.build
  end

  def create
    @reminder = Reminder.new(reminder_params)
    email = params[:reminder]&.dig(:users, :email)
    add_reminder_recipients(@reminder, [email])

    if @reminder.save # saves to db
      # save has worked
      # makes a new request to end this one
      redirect_to edit_reminder_path(@reminder)
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
    email = params[:reminder]&.dig(:users, :email)
    add_reminder_recipients(@reminder, [email])

    if @reminder.update(reminder_params)
      redirect_to edit_reminder_path(@reminder)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy
    logger.debug("destroy rem #{params[:id]}")

    # redirect_to root_path, status: :see_other
    redirect_to reminders_path, status: :see_other
  end

  private
    def reminder_params
      # params.require(:reminder).permit!
      params.require(:reminder)
      .permit(:date, users_attributes: [:email])
    end
end
