class Reminder < ApplicationRecord
  has_many :user_reminders, dependent: :destroy
  has_many :users, through: :user_reminders

  validates :date, presence: true
  validates :users,  presence: true

  def remove_recipients_by_email(emails)
    removed = []
    users.each do |user|
      if emails.include? user.email
        users.delete(user)
        removed << user
      end
    end
    removed
  end

  def add_recipients_by_email(emails)
    added = []
    emails.each { |email|
        user = User.find_by(email: email)
        if user
          users << user
        else user
          user = users.build(email: email)
        end
        added << user
    }
    added
  end
end
