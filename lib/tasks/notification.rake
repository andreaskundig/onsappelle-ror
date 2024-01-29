namespace :notification do
  desc "TODO"
  task send_due_reminders: :environment do
    now = Time.zone.now
    due_reminders = Reminder.due_for_sending_at(now)
    Rails.logger.info("#{due_reminders.size} reminders due for #{now}")
    print("#{due_reminders.size} reminders due for #{now}\n")
    due_reminders.each do |reminder|
      reminder.users.each do |recipient|
          UserMailer.with(email: recipient.email,
                          reminder: reminder)
            .remind_email.deliver_now
      end
      reminder.sent_at = DateTime.now
      unless reminder.save
        Rails.logger.error("Could set reminder.sent_at #{reminder.id}")
      end
    end

  end
end
