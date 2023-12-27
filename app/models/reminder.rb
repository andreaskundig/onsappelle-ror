class Reminder < ApplicationRecord
  has_many :user_reminders
  has_many :users, through: :user_reminders

  validates :date, presence: true
end
