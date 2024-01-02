require "application_system_test_case"

class RemindersTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit reminders_url

    assert_selector "h1", text: "Reminders"
  end


  test "create a reminder" do
    reminder_count = Reminder.count
    user_count = User.count

    visit new_reminder_path
    assert_selector "h1", text: "New Reminder"
    fill_in "reminder_date", with: Date.new(2023,1,4)
    fill_in "user_email", with: "create1@reminder.test"
    click_on "Add recipient"
    fill_in "user_email", with: "create2@reminder.test"
    click_on "Add recipient"
    click_on "Create reminder"

    assert_equal reminder_count + 1, Reminder.count
    assert_equal user_count + 2, User.count
  end
end
