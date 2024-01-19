class RemindersController < ApplicationController
  include ReminderFactory
  # skip_before_action :require_user!, only: [:new, :create]

  def index
    @reminders = Reminder.all
  end

  def show
    @reminder = Reminder.find(params[:id])
    @current_user ||= authenticate_by_session(User)
    logger.info("show HELLO, USER #{@current_user&.email}")
  end

  def new
    @reminder = Reminder.new
    @current_user ||= authenticate_by_session(User)
    logger.info("new HELLO, USER #{@current_user&.email}")
  end

  def create
    @reminder = Reminder.new(reminder_params)
    update_reminder_recipients(@reminder, params[:users])
    @current_user ||= authenticate_by_session(User)
    logger.info("create HELLO, USER #{@current_user&.email}")
    if @reminder.save # saves to db
      # save has worked
      unless @current_user
        @passwordless_link =
          passwordless_url_to(@reminder.users.first,
                              confirm_reminder_path(@reminder))
      end

      # email confirmation
      UserMailer.with(emails: @reminder.users.pluck(:email),
                      reminder: @reminder,
                      passwordless_link: @passwordless_link
                     )
        .added_to_reminder_email.deliver_later

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
      UserMailer.with(emails: changes[:added].map {|u| u.email},
                      reminder: @reminder)
        .added_to_reminder_email.deliver_later
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
