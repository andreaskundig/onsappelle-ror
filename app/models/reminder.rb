class Reminder < ApplicationRecord
  validates :date, presence: true
  has_many :user_reminders
  has_many :users, through: :user_reminders
end
