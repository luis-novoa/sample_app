require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "non-logged users are redirected to the login page" do
    get users_path
    assert_redirected_to login_url
    assert_not flash.empty?
  end

  test "logged users see a list of all users" do
    log_in_as(@user)
    get users_path
    assert_template "users/index"
    assert_select "h1", "All users"
    assert_select "a[href=?]", user_path(@other_user)
  end
end
