class RelationshipsController < ApplicationController
    before_action :logged_in_user

    def create
        #followed id is a hidden field in the _follow partial
        @user = User.find(params[:followed_id])
        current_user.follow(@user)
        respond_to do |format|
            format.html { redirect_to @user }
            format.js
        end
    end

    def destroy
        @user = Relationship.find(params[:id]).followed
        current_user.unfollow(@user)
        # works in browsers where JS is disabled
        # configuration added to config/application.rb to allow this
        respond_to do |format|
            format.html { redirect_to @user }
            format.js
        end
    end
end
