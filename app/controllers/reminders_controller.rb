class RemindersController < ApplicationController
  include ReminderFactory
 # it might be better to have this in the parent
 # but then it affects the default sign_in route
  before_action :require_user!
  skip_before_action :require_user!, only: [:new, :create]

  def index
    @reminders = current_user.reminders
    logger.info("index USER #{@current_user&.email}")
  end

  def show
    @reminder = Reminder.find(params[:id])
  end

  def new
    @reminder = Reminder.new
    if current_user
      @reminder.users << current_user
    end
  end

  def create
    @reminder = Reminder.new(reminder_params)
    update_reminder_recipients(@reminder, params[:users])
    # TODO if we have a user, mark the reminder as confirmed
    needs_confirmation = !current_user

    if @reminder.save # saves to db
      # save has worked

      # TODO include link to remove yourself from the reminder
      @reminder.users.each do |recipient|
        if needs_confirmation
          # ask for confirmation
          passwordless_link =
            passwordless_url_to(recipient,
                                confirm_reminder_path(@reminder))
          UserMailer.with(email: recipient.email,
                          reminder: @reminder,
                          passwordless_link: passwordless_link
                         )
            .ask_reminder_confirmation_email.deliver_later
        else
          passwordless_link =
            passwordless_url_to(recipient,
                                reminder_path(@reminder))
          # email confirmation
          UserMailer.with(email: recipient.email,
                          reminder: @reminder,
                          passwordless_link: passwordless_link
                         )
            .confirm_reminder_email.deliver_later
        end
      end

      # makes a new request to end this one
      redirect_to reminder_path(@reminder)
    else
      # just renders the view new.html.erb,
      # with an error, and without a new request
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @reminder = Reminder.find(params[:id])
    print("TODO SET A CONFIRMED FLAG\n")
    redirect_to reminder_path(@reminder)
  end

  def edit
    @reminder = Reminder.find(params[:id])
  end

  def update
    @reminder = Reminder.find(params[:id])
    changes =
      update_reminder_recipients(@reminder, params[:users])

    if @reminder.update(reminder_params)
      # email confirmation
      if changes
        @reminder.users do |recipient|
          passwordless_link =
            passwordless_url_to(recipient,
                                reminder_path(@reminder))
          # email confirmation
          UserMailer.with(email: recipient.email,
                          reminder: @reminder,
                          passwordless_link: passwordless_link
                         )
            .confirm_reminder_email.deliver_later
        end
      end
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

  private
    def passwordless_url_to(authenticatable,
                            destination_path = '')
      # see https://github.com/mikker/passwordless/blob/0428330d2ba0dfe9a8da36a854a39840740d4c84/test/passwordless/context_test.rb
      session = create_passwordless_session!(authenticatable)
      # creates link like this
      # http://localhost:3000/users/sign_in/c59c071d-12dc-4b01-85dc-5a6b0a964517/GDIFW1
      link = Passwordless.context.url_for(
        session,
        action: "confirm",
        id: session.to_param,
        token: session.token
      )
      return "#{link}?destination_path=#{destination_path}"
    end
    def reminder_params
      # params.require(:reminder).permit!
      params.require(:reminder)
      .permit(:date)
    end
end
