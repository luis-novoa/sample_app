require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @admin = users(:michael)
    @non_admin = users(:archer)
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

  test "index including pagination" do
    log_in_as(@user)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination", count: 2
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
      unless user == @admin
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select "a", text: "delete", count: 0
  end
end
