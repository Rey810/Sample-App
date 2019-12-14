class UsersController < ApplicationController
  # by default the before_action applies to every action in the controller but here it is resticted to the edit and update actions only. To catch any unauthorized users.
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  # Restricts access to the destroy action only to admin users. So, before going to the destroy action, the admin_user method is run. Prevents attackers from issuing DELETE requests directly from the command lineto delete any user on the site
  before_action :admin_user, only: :destroy

  def show
    @user = User.find(params[:id])

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
  
    if @user.save
      log_in @user
      flash[:success] = "Welcome to The Dark Side"  #flash message can now be used in the appropriate view
      redirect_to @user #rails infers from redirect_to that I want user_url(@user)
    else
      render 'new'
    end
  end

  def edit
  end

  #Note that paginate takes a hash argument with key :page and value equal to the page requested. User.paginate pulls the users out of the database one chunk at a time (30 by default), based on the :page parameter. So, for example, page 1 is users 1–30, page 2 is users 31–60, etc. If page is nil, paginate simply returns the first page.
  def index
    @users = User.paginate(page: params[:page])
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private 
    #use extra indentation for private methods
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters

    # Confirms a logged-in user
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user) # this is a helper method. #skinnyscontroller
    end

    # Confirms an admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end


end
