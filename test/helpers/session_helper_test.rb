require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

    def setup
        @user = users(:michael)
        remember(@user)
    end

    test "current_user returns right user when session is nil" do
        assert_equal @user, current_user
        assert is_logged_in?
    end

    # Checks that the current user is nil if the user's remember digest doesn't correspond correctly to the remember token, thereby testing the authenticated? method which compares the remember token to the remember digest
    test "current_user returns nil when remember digest is wrong" do
        @user.update_attribute(:remember_digest, User.digest(User.new_token)) # a new token is made therefore it won't match the remember digest made from the remember(@user) method
        assert_nil current_user
    end
end