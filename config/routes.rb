Rails.application.routes.draw do
  # if I leave this here, sign_in always redirects
  # to default language sign_in/xxxx
  # passwordless_for :users

  # https://dhampik.com/blog/rails-routes-tricks-with-locales
  root to: redirect("/#{I18n.locale || I18n.default_locale}", status: 302), as: :redirected_root

  post 'new_user_inputs', to: 'users#new_inputs'
  delete 'remove_user_inputs/:email_code', to: 'users#remove_inputs', as: :remove_user_inputs

  scope ":locale" do
    #this breaks sign_out because
    # link_to "Sign out", users_sign_out_path(@current_user)
    # becomes http://localhost:3000/1/users/sign_out
    # and en/users/sign_out redirects to /fr anyway...
    # and also breaks sign_in...
    passwordless_for :users

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
