module ReminderFactory
  extend ActiveSupport::Concern

  def reminder_has_email(reminder, email)
     reminder.users.find { |u| u.email == email }
  end

  def update_reminder_recipients(reminder, user_params)
    emails = user_params&.map {|u| u[:email]}
    return unless emails
    # TODO check validity centrally and tell user
    valid_emails = emails.map {|e| e.strip}
                     .filter {|e| not (e.nil? or e.empty?)}
    recipient_emails = reminder.users.map {|u| u.email}
    to_remove = recipient_emails - valid_emails
    to_add = valid_emails - recipient_emails
    changes = {:removed => [], :added => [] }
    # remove
    reminder.users.each do |user|
      if to_remove.include? user.email
        reminder.users.delete(user)
        changes[:removed] << user
      end
    end
    # add
    to_add.each { |email|
        user = User.find_by(email: email)
        if user
          reminder.users << user
        else user
          reminder.users.build(email: email)
        end
        changes[:added] << user
    }
    changes
  end
end
