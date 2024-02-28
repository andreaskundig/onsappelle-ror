require "test_helper"
require "nokogiri"

class ReminderFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/en/"
    assert_select "h1", "Don't drift apart"
  end

  def get_email_html_body(email)
    email_html = email.html_part.body.to_s
    Nokogiri::HTML(email_html)
  end

  test "can create and confirm a reminder fr" do
    host! "localhost"
    get "/fr/reminders/new"
    assert_response :success

    the_email = 'welcome@test.com'

    reminder_count = Reminder.count
    old_reminder = Reminder.last
    assert_not_equal the_email, old_reminder.users[0].email
    emails = capture_emails do
        post "/fr/reminders/",
             params: { reminder: { date: "2023-12-21"},
                       users: [{ email: the_email }] }
    end
    assert_equal 1, emails.size
    assert_response :redirect
    assert_redirected_to %r{^http://localhost.*}

    sent_email_doc = Nokogiri::HTML( emails.first.html_part.body.to_s)
    sent_email_links = sent_email_doc.css('a')
    assert_equal 1, sent_email_links.size
    email_confirm_link = sent_email_links.first
    assert_equal 'confirmer', email_confirm_link.text

    assert_equal reminder_count + 1, Reminder.count
    new_reminder = Reminder.last
    assert_equal DateTime.new(2023, 12, 21), new_reminder.date
    assert_equal the_email, new_reminder.users[0].email
    assert_nil new_reminder.confirmed_at
    assert_equal 'fr', new_reminder.locale

    # follow_redirect!
    # assert_response :found
    # assert_response :success
    # assert_select "h1", "Reminder #{new_reminder.id}"
    # assert_select "span", the_email
    #
    email_confirm_href = email_confirm_link.attribute("href").to_s
    sign_in_url = email_confirm_href.sub('http://localhost:3000', '')
    confirm_url = sign_in_url.sub(/.*destination_path=/, '')

    get sign_in_url
    assert_response :see_other
    assert_redirected_to %r{^http://localhost/fr/reminders/.*/confirm}

    get confirm_url
    assert_response :found
    assert_redirected_to %r{^http://localhost/fr/reminders/}
    assert_redirected_to new_reminder

    follow_redirect!
    assert_response :success
    assert_select "h1", "Rappel"
    assert_select "span", the_email

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
        post "/en/reminders/",
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
        post "/en/reminders/",
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
        post "/fr/reminders/",
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
        post "/fr/reminders/",
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

    patch "/en/reminders/#{reminder.id}",
          params: { reminder: { date: the_date},
                    users: [{ email: the_email }]}
    assert_response :redirect

    # no update without logging in
    new_reminder = Reminder.find(reminder.id)
    new_date = new_reminder.date.strftime('%Y-%m-%d')
    assert_equal original_date, new_date

    user =  User.first
    emails = capture_emails do
        post users_sign_in_path,
             params: { "passwordless[email]"=>  user.email }
    end
    email_text = emails.first.to_s
    urls = email_text.scan(/(http[s]?:\/\/\S+)/)
    sign_in_url = urls.first.first
    assert_match %r{/en/users/sign_in/}, sign_in_url

    get sign_in_url
    assert_response :redirect
    assert_redirected_to 'http://localhost/'

    #TODO find a way to redirect to /en, not /fr
    follow_redirect!
    assert_response :redirect
    assert_redirected_to 'http://localhost/fr'

    follow_redirect!
    assert_response :success

    patch "/en/reminders/#{reminder.id}",
          params: { reminder: { date: the_date},
                    users: [{ email: the_email }]}
    assert_response :redirect

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

    patch "/en/reminders/#{reminder.id}",
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
