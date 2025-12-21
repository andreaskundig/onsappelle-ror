require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  test "should not save reminder without date" do
    reminder = Reminder.new
    assert_not reminder.save, 'Saved reminder without title'
  end

  test "due_for_sending_at selects correct reminders" do
    now = DateTime.parse("2024-01-29 16:30:00")
    due_reminders = Reminder.due_for_sending_at(now)
    assert_equal 1, due_reminders.size

    expected_reminder = Reminder.find_by(
      date: Date.parse("2023-12-27"))
    assert_equal expected_reminder, due_reminders.first
  end
end
