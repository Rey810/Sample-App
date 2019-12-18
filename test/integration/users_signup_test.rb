require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
    #  the deliveries array is global so it must be reset in the setup method to prevent our code from breaking if any other tests deliver email
    def setup
      ActionMailer::Base.deliveries.clear
    end

    #assert_no_difference checks for a difference between User.count before and after the contents of the assert_no_difference block. Equivalent to recording the user count, posting the data, and verifying that the count is the same:
    #before_count = User.count
    #post users_path, ...
    #after_count  = User.count
    #assert_equal before_count, after_count
    test "invalid signup information" do
      get signup_path
      assert_no_difference 'User.count' do            
        post users_path, params: { user: {  name: "",
                                            email: "user@invalid", 
                                            password:              "foo",
                                            password_confirmation: "bar" } }
      end
      assert_template 'users/new'       #checks that a failed submission re-renders the 'new' action
      assert_select 'div#error_explanation' #returns true when it has found these
      assert_select 'div.field_with_errors' #returns true when it has found these
    end

    #For this test to work, it’s necessary for the Users routes the Users show action and the show.html.erb view to work correctly
    test "valid signup information with account activation" do
      get signup_path
      assert_difference 'User.count', 1 do
        post users_path, params: { user: { name:  "Example User",
                                           email: "user@example.com",
                                           password:              "password",
                                           password_confirmation: "password" } }
      end
      # verifies that exactly 1 message was delivered.
      assert_equal 1, ActionMailer::Base.deliveries.size
      # 'assigns' lets us access instance variables in the corresponding action
      user = assigns(:user)
      assert_not user.activated?
      # Try to log in before activation.
      log_in_as(user)
      assert_not is_logged_in?
      # Invalid activation token
      get edit_account_activation_path("invalid token", email: user.email)
      assert_not is_logged_in?
      # Valid token, wrong email
      get edit_account_activation_path(user.activation_token, email: 'wrong')
      assert_not is_logged_in?
      # Valid activation token
      get edit_account_activation_path(user.activation_token, email: user.email)
      assert user.reload.activated?
      follow_redirect!
      assert_template 'users/show'
      assert is_logged_in?
    end
end
     
      