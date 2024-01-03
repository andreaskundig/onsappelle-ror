Rails.application.routes.draw do
  root "reminders#new"

  post 'new_user_inputs', to: 'users#new_inputs'
  delete 'remove_user_inputs/:email_code', to: 'users#remove_inputs', as: :remove_user_inputs

  # https://api.rubyonrails.org/v7.1.2/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
  resources :reminders do
    resources :users do
    end
  end
end
