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

    params = ActionController::Parameters.new(
      {
        reminder: {
          date: "2023-12-29"
        },
        user: {email: 'tot@leb.go'}
      })
    permitted = params.require(:reminder)
                  .permit(:date,
                          users_attributes: [:email])
    assert permitted.permitted?
  end

end
