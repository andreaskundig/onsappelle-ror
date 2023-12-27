class RemindersController < ApplicationController
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

  private
    def reminder_params
      params.require(:reminder).permit(:date)
    end
end
