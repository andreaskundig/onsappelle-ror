class Reminder < ApplicationRecord
  has_many :user_reminders, dependent: :destroy
  has_many :users, through: :user_reminders

  validates :date, presence: true
  validates :users,  presence: true
end
