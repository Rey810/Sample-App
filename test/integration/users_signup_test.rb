require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest


    #assert_no_difference checks for a difference between User.count before and after the contents of the assert_no_difference block. Equivalent to recording the user count, posting the data, and verifying that the count is the same:
    #before_count = User.count
    #post users_path, ...
    #after_count  = User.count
    #assert_equal before_count, after_count
    test "invalid signup information" do
      get signup_path
      assert_no_difference 'User.count' do            
        post signup_path, params: { user: {  name: "",
                                            email: "user@invalid", 
                                            password:              "foo",
                                            password_confirmation: "bar" } }
      end
      assert_template 'users/new'       #checks that a failed submission re-renders the 'new' action
      assert_select 'div#error_explanation' #returns true when it has found these
      assert_select 'div.field_with_errors' #returns true when it has found these
    end

    #For this test to work, it’s necessary for the Users routesthe Users show action and the show.html.erb viewto work correctly
    test "valid signup information" do
      get signup_path
      assert_difference 'User.count', 1 do  #checks for a difference of 1 before and after the block
        post users_path, params: { user: {  name: "Example User", 
                                            email: "suer@example.com",
                                            password:               "password",
                                            password_confirmation:  "password" } }
      end
      follow_redirect!
      assert_template 'users/show'    #This is a sensitive test for almost everyhting related to a user's profile due to what needs to happen to end up here. 
      assert_not flash.empty?
    end
end
