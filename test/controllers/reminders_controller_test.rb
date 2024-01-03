require "test_helper"

class RemindersControllerTest < ActionDispatch::IntegrationTest
  test "should get reminders" do
    get reminders_url
    assert_response :success
  end

  test "parameter permissions" do
    # We can get the controller,
    # but @controller.reminder_params is private...

    # get reminders_url
    # print("CONT #{@controller}")
    ActionController::Parameters.action_on_unpermitted_parameters = :raise
    params = ActionController::Parameters.new(
      {
        reminder: {
          date: "2023-12-29",
        },
        users:[{email: 'tot@leb.go'}]
      })
    reminder_permitted = params.require(:reminder)
                  .permit(:date)
    assert reminder_permitted.permitted?
    users_permitted = params.require(:users)[0]
                  .permit([:email])
    assert users_permitted.permitted?
  end

  test "permissions for create Reminder" do
    # We can get the controller,
    # but @controller.reminder_params is private...

    # get reminders_url
    # print("CONT #{@controller}")
    params = ActionController::Parameters.new(
      {
        reminder: {
          date: "2023-12-29",
        },
        users:[{email: 'tot@leb.go'}]
      })
    permitted = params.require(:reminder)
                  .permit(:date, { users: :email })
    Reminder.new(permitted)
  end
end
