require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  test "should not save reminder without date" do
    reminder = Reminder.new
    assert_not reminder.save, 'Saved reminder without title'
  end
end
