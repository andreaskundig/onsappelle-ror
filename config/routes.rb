Rails.application.routes.draw do
  root "reminders#new"

  post 'new_user_inputs', to: 'users#new_inputs'

  # https://api.rubyonrails.org/v7.1.2/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
  resources :reminders do
    resources :users do
      # https://api.rubyonrails.org/v7.1.2/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
      member do
        delete 'remove', to: 'reminders#remove_user'
      end
    end
  end
end
