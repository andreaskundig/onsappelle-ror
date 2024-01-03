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
     reminder.users.find { |u| u.email == email }
  end

  def add_reminder_recipients(reminder, user_params)
    emails = user_params&.map {|u| u[:email]}
    return unless emails
    reminder.users.each do |user|
      unless emails.include? user.email
        reminder.users.delete(user)
      end
    end
    emails&.each{ |email|
      invalid = (email.nil? or email.empty?)
      unless invalid or reminder_has_email(reminder, email)
        email.strip!
        user = User.find_by(email: email)
        if user
          reminder.users << user
        else user
          reminder.users.build(email: email)
        end
      end
    }
  end
end
