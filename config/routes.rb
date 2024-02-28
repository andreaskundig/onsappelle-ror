Rails.application.routes.draw do

  # https://dhampik.com/blog/rails-routes-tricks-with-locales
  root to: redirect("/#{I18n.locale || I18n.default_locale}", status: 302), as: :redirected_root

  post 'new_user_inputs', to: 'users#new_inputs'
  delete 'remove_user_inputs/:email_code', to: 'users#remove_inputs', as: :remove_user_inputs

  scope "/:locale" do
    # passwordless_for :users
    passwordless_for :users, controller: 'my_passwordless_sessions'

    get 'request_confirmation', to: 'reminders#request_confirmation'
    # https://api.rubyonrails.org/v7.1.2/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
    resources :reminders do
      resources :users do
      end
      member do
        get 'confirm'
      end
    end
    # https://stackoverflow.com/questions/6180130/using-rails-3-root-path-and-root-to-with-locale-url-paths
    root "reminders#new"
  end
end
