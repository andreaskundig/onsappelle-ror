class RemindersController < ApplicationController
  include ReminderFactory
 # it might be better to have this in the parent
 # but then it affects the default sign_in route
  before_action :require_user!
  skip_before_action :require_user!, only: [:new, :create]
  before_action :find_and_authorize_reminder,
                only: [:show, :destroy, :confirm, :update, :edit]

  def index
    @reminders = current_user.reminders
    logger.info("index USER #{@current_user&.email}")
  end

  def show
    # @reminder is set by :find_and_authorize_reminder
  end

  def new
    @reminder = Reminder.new
    if current_user
      @reminder.users << current_user
    end
  end

  def create
    @reminder = Reminder.new(reminder_params)
    @reminder.confirmed_at = Time.zone.now if current_user
    update_reminder_recipients(@reminder, params[:users])
    locale = params[:locale]

    if @reminder.save # saves to db
      # save has worked

      # TODO include link to remove yourself from the reminder
      @reminder.users.each do |recipient|
        if !@reminder.confirmed_at
          # ask for confirmation
          passwordless_link =
            passwordless_url_to(recipient,
                                locale,
                                confirm_reminder_path(@reminder))
          UserMailer.with(email: recipient.email,
                          reminder: @reminder,
                          passwordless_link: passwordless_link
                         )
            .ask_reminder_confirmation_email.deliver_later
        else
          passwordless_link =
            passwordless_url_to(recipient,
                                locale,
                                reminder_path(@reminder))
          # email confirmation
          UserMailer.with(email: recipient.email,
                          reminder: @reminder,
                          passwordless_link: passwordless_link
                         )
            .confirm_reminder_email.deliver_later
        end
      end

      # TODO redirect to some confirmation unless current user
      # maybe the login page with an extra message?

      # makes a new request to end this one
      redirect_to reminder_path(@reminder)
    else
      # just renders the view new.html.erb,
      # with an error, and without a new request
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    # @reminder is set by :find_and_authorize_reminder
    @reminder.confirmed_at = Time.zone.now if current_user
    if @reminder.save # saves to db
      redirect_to reminder_path(@reminder)
    else
      # TODO show something more like a server error
      render :show, status: :unprocessable_entity
    end
  end

  # TODO check if this is really used
  def edit
    # @reminder is set by :find_and_authorize_reminder
  end

  def update
    # @reminder is set by :find_and_authorize_reminder
    locale = params[:locale]
    changes =
      update_reminder_recipients(@reminder, params[:users])

    if @reminder.update(reminder_params)
      # email confirmation
      if changes
        @reminder.users do |recipient|
          passwordless_link =
            passwordless_url_to(recipient,
                                locale,
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
    # @reminder is set by :find_and_authorize_reminder
    @reminder.destroy
    redirect_to root_path, status: :see_other
  end

  private
  def passwordless_url_to(authenticatable,
                          locale,
                          destination_path = '')
      # see https://github.com/mikker/passwordless/blob/0428330d2ba0dfe9a8da36a854a39840740d4c84/test/passwordless/context_test.rb
      session = create_passwordless_session!(authenticatable)
      # creates link like this
      # http://localhost:3000/users/sign_in/c59c071d-12dc-4b01-85dc-5a6b0a964517/GDIFW1
      # debugger
      link = Passwordless.context.url_for(
        session,
        action: "confirm",
        id: session.to_param,
        token: session.token,
        locale: locale
      )
      return "#{link}?destination_path=#{destination_path}"
    end

    def find_and_authorize_reminder
      @reminder = current_user.reminders.find_by(id: params[:id])
      unless @reminder
        # return head :forbidden
        # redirect_to root_path, status: :forbidden
        redirect_to root_path, status: :see_other
      end
    end

    def reminder_params
      # params.require(:reminder).permit!
      params.require(:reminder)
      .permit(:date)
    end
end
