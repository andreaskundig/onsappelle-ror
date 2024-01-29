require "test_helper"
require "nokogiri"

class ReminderFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "New Reminder"
  end

  test "can create a reminder" do
    get "/reminders/new"
    assert_response :success

    the_email = 'welcome@test.com'

    reminder_count = Reminder.count
    old_reminder = Reminder.last
    assert_not_equal the_email, old_reminder.users[0].email
    sent_emails = capture_emails do
        post "/reminders/",
             params: { reminder: { date: "2023-12-21"},
                       users: [{ email: the_email }] }
    end
    assert_equal 1, sent_emails.size
    assert_response :redirect

    sent_email_html = "#{sent_emails.first.html_part.body}"
    sent_email_doc = Nokogiri::HTML(sent_email_html)
    sent_email_links = sent_email_doc.css('a')
    assert_equal 1, sent_email_links.size
    email_confirm_link = sent_email_links.first
    assert_equal 'confirm reminder', email_confirm_link.text

    assert_equal reminder_count + 1, Reminder.count
    new_reminder = Reminder.last
    assert_equal DateTime.new(2023, 12, 21), new_reminder.date
    assert_equal the_email, new_reminder.users[0].email
    assert_nil new_reminder.confirmed_at

    # follow_redirect!
    # assert_response :found
    # assert_response :success
    # assert_select "h1", "Reminder #{new_reminder.id}"
    # assert_select "span", the_email
    #
    email_confirm_href = email_confirm_link.attribute("href").to_s
    print("\033[33m #{email_confirm_href}\n")
    sign_in_url = email_confirm_href.sub('http://localhost:3000', '')
    confirm_url = sign_in_url.sub(/.*destination_path=/, '')

    #TODO fix test redirect: not to example.com
    get sign_in_url
    assert_response :see_other

    get confirm_url
    assert_response :found

    # follow_redirect!
    # assert_response :found
    # assert_response :success
    # assert_select "h1", "Reminder #{new_reminder.id}"
    # assert_select "span", the_email

    new_reminder.reload
    refute_nil new_reminder.confirmed_at
  end

  test "can create two reminders" do

    reminder_count = Reminder.count

    # reminder 0
    email_0 = 'create_0@test.com'
    datetime_0 = DateTime.new(2023, 12, 10)
    date_0 = datetime_0.strftime('%Y-%m-%d')
    assert_emails 1 do
        post "/reminders/",
             params: { reminder: { date: date_0},
                       users: [{ email: email_0 }]}
    end
    assert_response :redirect

    assert_equal reminder_count + 1, Reminder.count
    reminder_0 = Reminder.last
    assert_equal datetime_0, reminder_0.date
    assert_equal 1, reminder_0.users.length
    assert_equal email_0, reminder_0.users[0].email

    # reminder 1
    email_1 = 'create_1@test.com'
    datetime_1 = DateTime.new(2123, 12, 11)
    date_1 = datetime_1.strftime('%Y-%m-%d')
    assert_emails 1 do
        post "/reminders/",
             params: { reminder: { date: date_1},
                       users: [{ email: email_1 }] }
    end
    assert_response :redirect
    assert_equal reminder_count + 2, Reminder.count
    reminder_1 = Reminder.last
    assert_equal datetime_1, reminder_1.date
    assert_equal 1, reminder_1.users.length
    assert_equal email_1, reminder_1.users[0].email
  end

  test "can create two reminders with same email" do

    reminder_count = Reminder.count
    the_email = '2rem1em@test.com'

    # reminder 0
    datetime_0 = DateTime.new(2023, 12, 10)
    date_0 = datetime_0.strftime('%Y-%m-%d')
    assert_emails 1 do
        post "/reminders/",
             params: { reminder: { date: date_0},
                       users: [{ email: the_email }]}
    end
    assert_response :found

    assert_equal reminder_count + 1, Reminder.count
    reminder_0 = Reminder.last
    assert_nil reminder_0.confirmed_at
    assert_equal datetime_0, reminder_0.date
    assert_equal 1, reminder_0.users.length
    assert_equal the_email, reminder_0.users[0].email

    # reminder 1
    datetime_1 = DateTime.new(2123, 12, 11)
    date_1 = datetime_1.strftime('%Y-%m-%d')
    assert_emails 1 do
        post "/reminders/",
             params: { reminder: { date: date_1},
                       users: [{ email: the_email }]}
    end
    assert_response :redirect
    assert_equal reminder_count + 2, Reminder.count
    reminder_1 = Reminder.last
    assert_nil reminder_1.confirmed_at
    assert_equal datetime_1, reminder_1.date
    assert_equal 1, reminder_1.users.length
    assert_equal the_email, reminder_1.users[0].email
  end

  test "can update a reminder" do
    the_email = 'update@updaty.com'
    the_date = '2221-02-01'

    reminder = Reminder.first
    original_date = reminder.date.strftime('%Y-%m-%d')
    assert_not_equal the_date, original_date
    old_emails = reminder.users.map { |u| u.email }
    assert_not_includes old_emails, the_email

    patch "/reminders/#{reminder.id}",
          params: { reminder: { date: the_date},
                    users: { email: the_email }}
    assert_response :redirect

    # no update without logging in
    new_reminder = Reminder.find(reminder.id)
    new_date = new_reminder.date.strftime('%Y-%m-%d')
    assert_equal original_date, new_date

    # TODO log in
    # new_reminder = Reminder.find(reminder.id)
    # new_date = new_reminder.date.strftime('%Y-%m-%d')
    # assert_equal the_date, new_date
    # new_emails = new_reminder.users.map { |u| u.email }
    # assert_includes new_emails, the_email
    # assert_equal old_emails.length + 1, new_emails.length

    # follow_redirect!
    # assert_response :success
  end

  test "can update a reminder with empty email" do
    the_date = '2221-02-01'

    reminder = Reminder.first
    original_date = reminder.date.strftime('%Y-%m-%d')
    assert_not_equal the_date, original_date

    patch "/reminders/#{reminder.id}",
          params: { reminder: { date: the_date},
                    users: { email: '' }}
    assert_response :found

    new_reminder = Reminder.find(reminder.id)
    new_date = new_reminder.date.strftime('%Y-%m-%d')
    assert_equal original_date, new_date

    # patch "/reminders/#{reminder.id}",
    #       params: { reminder: { date: the_date},
    #                 users: { email: '' }}
    # assert_response :redirect
    #TODO log in
    # new_reminder = Reminder.find(reminder.id)
    # new_date = new_reminder.date.strftime('%Y-%m-%d')
    # assert_equal the_date, new_date
  end
end
