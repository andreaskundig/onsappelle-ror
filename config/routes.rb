Rails.application.routes.draw do
  root "reminders#index"

  get "/reminders", to: "reminders#index"

  get "up" => "rails/health#show", as: :rails_health_check

end
