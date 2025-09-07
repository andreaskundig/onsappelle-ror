module ReminderFactory
  extend ActiveSupport::Concern

  def reminder_has_email(reminder, email)
     reminder.users.find { |u| u.email == email }
  end

  def update_reminder_recipients(reminder, user_params)
    emails = user_params&.map {|u| u[:email]}
    return nil unless emails
    # TODO check validity centrally and tell user
    valid_emails = emails.map {|e| e.strip}
                     .filter {|e| not (e.nil? or e.empty?)}
    recipient_emails = reminder.users.map {|u| u.email}
    to_remove = recipient_emails - valid_emails
    to_add = valid_emails - recipient_emails
    return {
      removed: reminder.remove_recipients_by_email(to_remove),
      added: reminder.add_recipients_by_email(to_add)
    }
  end

  def date_change?(old_date_object, new_date_string)
    new_parsed_date = nil
    begin
      new_parsed_date = Date.parse(new_date_string)
      return new_parsed_date != old_date_object
    rescue ArgumentError
    end
    return false
  end
end
