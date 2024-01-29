require 'test_helper'
require 'rake'

class NotificationTaskTest <  ActionDispatch::IntegrationTest

    test "should send due reminders" do
      OnsappelleRor::Application.load_tasks if Rake::Task.tasks.empty?
      travel_to Time.zone.local(2024, 01, 29) do
        now = Time.zone.now
        due = Reminder.due_for_sending_at(now)
        assert_equal 1, due.size
        emails = capture_emails do
          Rake::Task["notification:send_due_reminders"].invoke
        end
        assert_equal 2, emails.size
        email = emails.first
        assert_equal 2, email.reply_to.size
        new_due = Reminder.due_for_sending_at(now)
        assert_equal 0, due.size
      end
    end

end
