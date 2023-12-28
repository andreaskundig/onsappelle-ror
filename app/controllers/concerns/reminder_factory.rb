module ReminderFactory
  extend ActiveSupport::Concern

  def upsert_reminder(reminder_id, date, emails)
    reminder = Reminder.find(reminder_id)
    unless reminder
      reminder = Reminder.new(date: date)
    end
    reminder.save
  end

  def reminder_has_email(reminder, email)
    email and reminder.users.find { |u| u.email == email }
  end

  def add_reminder_recipients(reminder, emails)
    emails.each{ |email|
      unless reminder_has_email(reminder, email)
        email.strip!
        user = User.find_by(email: email)
        if user
          reminder.users << user
        else user
          reminder.users.build(email: email)
        end
      end
    }
    reminder.save
  end
end
