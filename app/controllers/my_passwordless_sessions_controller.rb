class MyPasswordlessSessionsController < Passwordless::SessionsController
    def create
      handle_resource_not_found unless @resource = find_authenticatable
      @session = build_passwordless_session(@resource)

      if @session.save
        call_after_session_save

        redirect_to(
          Passwordless.context.path_for(
            @session,
            id: @session.to_param,
            action: "show",
            **default_url_options
          ),
          flash: {notice: I18n.t("passwordless.sessions.create.email_sent")}
        )
      else
        flash[:error] = I18n.t("passwordless.sessions.create.error")
        render(:new, status: :unprocessable_entity)
      end

    rescue ActiveRecord::RecordNotFound
      @session = Session.new

      flash[:error] = I18n.t("passwordless.sessions.create.not_found")
      render(:new, status: :not_found)
    end
end
