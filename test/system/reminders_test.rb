require "application_system_test_case"

class RemindersTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit reminders_url

    assert_selector "h1", text: "Reminders"
  end


  test "can create a reminder" do
    reminder_count = Reminder.count
    user_count = User.count
    email1 = "create1@reminder.test"
    email2 = "create2@reminder.test"


    visit new_reminder_path
    assert_selector "h1", text: "New Reminder"
    fill_in "reminder_date", with: Date.new(2023,1,4)
    fill_in "user_email", with: email1
    click_on "Add recipient"
    fill_in "user_email", with: email2
    click_on "Add recipient"


    assert_equal reminder_count, Reminder.count
    assert_equal user_count, User.count

    click_on "Create reminder"

    assert_equal reminder_count + 1, Reminder.count
    assert_equal user_count + 2, User.count

    new_reminder = Reminder.last
    assert_equal DateTime.new(2023, 1, 4), new_reminder.date
    assert_equal email1, new_reminder.users[0].email
    assert_equal email2, new_reminder.users[1].email
  end
end
