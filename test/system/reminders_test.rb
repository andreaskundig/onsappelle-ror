require "application_system_test_case"

# Prevent test helper from overriding mail delivery method
# https://stackoverflow.com/questions/57776074/rails-6-deliver-later-doesnt-affect-actionmailerbase-deliveries
module ActiveJob
  module TestHelper
    def before_setup
      super
    end
  end
end

class RemindersTest < ApplicationSystemTestCase
  include UsersHelper
  include ActionMailer::TestHelper

  # failing workaround
    # https://github.com/rails/rails/issues/37270
  # def setup
  #     (ActiveJob::Base.descendants << ActiveJob::Base).each(&:disable_test_adapter)
  # end

  test "visiting the index" do
    visit reminders_url

    assert_selector "h1", text: "Reminders"
  end

  test "can create a reminder" do
    reminder_count = Reminder.count
    user_count = User.count
    p = Time.now.strftime("%H-%M-%S-%L-")
    email1 = p+"create1@reminder.test"
    email2 = p+"create2@reminder.test"
    email3 = p+"create3@reminder.test"


    visit new_reminder_path
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
    assert_selector "a[href$='#{email_to_code(email3)}']", text: '[-]'

    find("a[href$='#{email_to_code(email3)}']").click
    assert_no_selector "span", text: email3

    assert_equal reminder_count, Reminder.count
    assert_equal user_count, User.count

    assert File.exist?("tmp/mails/12-11-39-332-create1@reminder.test")

    assert !File.exist?("tmp/mails/#{email1}")
    # a bug breaks assert_emails
    # https://github.com/rails/rails/issues/37270
    # https://stackoverflow.com/questions/57776074/rails-6-deliver-later-doesnt-affect-actionmailerbase-deliveries
    # perform_enqueued_jobs do
    # assert_emails 1 do
    #     click_on "Create reminder"
    # end
    # end
    perform_enqueued_jobs do
      click_on "Create reminder"
    end
    until File.exist?("tmp/mails/#{email1}")
        sleep(5)
    end
    assert File.exist?("tmp/mails/#{email1}")

    assert_equal reminder_count + 1, Reminder.count
    assert_equal user_count + 2, User.count

    new_reminder = Reminder.last
    assert_equal DateTime.new(2023, 1, 4), new_reminder.date
    assert_equal 2, new_reminder.users.length
    assert_equal email1, new_reminder.users[0].email
    assert_equal email2, new_reminder.users[1].email
  end

  test "can update a reminder" do
    reminder = Reminder.last
    user_count = reminder.users.count
    assert_equal 1, user_count
    user1 =  reminder.users[0]
    email1 = user1.email
    email2 = "update2@reminder.test"
    email3 = "update3@reminder.test"

    visit reminder_path(reminder)
    assert_selector "h1", text: "Reminder #{reminder.id}"
    assert_selector "span", text: email1
    assert_no_selector "span", text: email2
    assert_no_selector "span", text: email3

    fill_in "user_email", with: email2
    click_on "Add recipient"
    assert_selector "span", text: email2

    fill_in "user_email", with: email3
    click_on "Add recipient"
    assert_selector "span", text: email3


    assert_selector "a[href$='#{email_to_code(email1)}']", text: '[-]'

    find("a[href$='#{email_to_code(email1)}']").click
    assert_no_selector "span", text: email1

    click_on "Update reminder"

    reminder.reload
    assert_equal user_count + 1, reminder.users.count

    assert_equal email2, reminder.users[0].email
    assert_equal email3, reminder.users[1].email
  end
end
