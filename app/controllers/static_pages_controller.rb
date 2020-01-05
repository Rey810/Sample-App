class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # creates an instance of micropost through its associations
      @micropost  = current_user.microposts.build 
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
