module ReminderFactory
  extend ActiveSupport::Concern

  def upsert_reminder(reminder_id, date, emails)
    reminder = Reminder.find(reminder_id)
    unless reminder
      reminder = Reminder.new(date: date)
    end
    reminder.save
  end

  def add_reminder_recipients(reminder, emails)
    emails.each{ |email|
      if email
        email.strip!
        user = User.find_by(email: email)
        unless user
            user = reminder.users.build(email: email)
        end
      end
    }
    reminder.save
  end
end
