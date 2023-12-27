class User < ApplicationRecord
  has_many :user_reminders
  has_many :reminders, through: :user_reminders
end
