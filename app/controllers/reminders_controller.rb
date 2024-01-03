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
    add_reminder_recipients(@reminder, params[:users])

    if @reminder.save # saves to db
      # save has worked
      # makes a new request to end this one
      redirect_to reminder_path(@reminder)
    else
      # just renders the view new.html.erb,
      # with an error, and without a new request
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @reminder = Reminder.find(params[:id])
  end

  def update
    @reminder = Reminder.find(params[:id])
    add_reminder_recipients(@reminder, params[:users])

    if @reminder.update(reminder_params)
      redirect_to reminder_path(@reminder)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id])
    @reminder.destroy

    # redirect_to root_path, status: :see_other
    redirect_to reminders_path, status: :see_other
  end

  def remove_user
    @reminder = Reminder.find(params[:reminder_id])
    @user = @reminder.users.find(params[:id])

    if @reminder.users.delete(@user)
      respond_to do |format|
        format.html { redirect_to reminder_path(@reminder) }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end

  end

  private
    def reminder_params
      # params.require(:reminder).permit!
      params.require(:reminder)
      .permit(:date)
    end
end
