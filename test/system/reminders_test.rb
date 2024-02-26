require "application_system_test_case"


class RemindersTest < ApplicationSystemTestCase
  include UsersHelper

  test "visiting reminders/new" do
    visit new_reminder_path(locale: 'en')

    assert_selector "h1", text: "New Reminder"
  end

  test "can create a reminder" do
    reminder_count = Reminder.count
    user_count = User.count
    email1 = "create1@reminder.test"
    email2 = "create2@reminder.test"
    email3 = "create3@reminder.test"


    visit new_reminder_path(locale: 'en')
    assert_selector "h1", text: "New Reminder"
    assert_no_selector "span", text: email1
    assert_no_selector "span", text: email2

    fill_in "reminder_date", with: Date.new(2023,1,4)
    fill_in "user_email", with: email1
    click_on "Add recipient"
    assert_selector "span", text: email1

    fill_in "user_email", with: email2
    click_on "Add recipient"
    assert_selector "span", text: email2

    fill_in "user_email", with: email3
    click_on "Add recipient"

    assert_selector "span", text: email3
    assert_selector "a[href*='#{email_to_code(email3)}']", text: '[-]'

    find("a[href*='#{email_to_code(email3)}']").click
    assert_no_selector "span", text: email3

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

  test "can update a reminder" do
    # reminder = Reminder.last
    # user_count = reminder.users.count
    # assert_equal 1, user_count
    # user1 =  reminder.users[0]
    # email1 = user1.email
    # email2 = "update2@reminder.test"
    # email3 = "update3@reminder.test"

    #TODO log in

    # visit reminder_path(reminder)
    # assert_selector "h1", text: "Reminder #{reminder.id}"
    # assert_selector "span", text: email1
    # assert_no_selector "span", text: email2
    # assert_no_selector "span", text: email3

    # fill_in "user_email", with: email2
    # click_on "Add recipient"
    # assert_selector "span", text: email2

    # fill_in "user_email", with: email3
    # click_on "Add recipient"
    # assert_selector "span", text: email3


    # assert_selector "a[href$='#{email_to_code(email1)}']", text: '[-]'

    # find("a[href$='#{email_to_code(email1)}']").click
    # assert_no_selector "span", text: email1

    # click_on "Update reminder"

    # reminder.reload
    # assert_equal user_count + 1, reminder.users.count

    # assert_equal email2, reminder.users[0].email
    # assert_equal email3, reminder.users[1].email
  end
end
