class Reminder < ApplicationRecord
  has_many :user, through: :user_reminders
end
