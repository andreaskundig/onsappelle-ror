require "test_helper"

class ReminderFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "New Reminder"
  end

  test "can create an reminder" do
    get "/reminders/new"
    assert_response :success

    reminder_count = Reminder.count
    old_reminder = Reminder.last
    assert_not_equal 'fa@rfa.lo', old_reminder.users[0].email

    post "/reminders/",
         params: { reminder: { date: "2023-12-21",
                               users: { email: 'fa@rfa.lo' }} }
    assert_response :redirect

    assert_equal reminder_count + 1, Reminder.count
    new_reminder = Reminder.last
    assert_equal Date.new(2023, 12, 21), new_reminder.date
    assert_equal 'fa@rfa.lo', new_reminder.users[0].email

    follow_redirect!
    assert_response :success
    assert_select "h1", "Reminder #{new_reminder.id}"
  end

  test "can update a reminder" do
    reminder = Reminder.first

    get "/reminders/#{reminder.id}/edit"
    assert_response :success
    assert_select "h1", "Edit Reminder"

  end
end
