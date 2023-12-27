Rails.application.routes.draw do
  root "reminders#index"

  # https://api.rubyonrails.org/v7.1.2/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources
  resources :reminders
end
