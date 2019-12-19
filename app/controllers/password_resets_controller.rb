class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]  

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  # This is what happens after the form in edit.html.erb is submitted
  def update
    # a failed update due to an empty password
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    # a successful update
    elsif @user.update_attributes(user_params)
      log_in @user
      # the password reset link remains active for 2 hours and can be used even if logged out
      # setting the reset_digest to nil prevents another person pressing back on the browser and changing the password.
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset"
      redirect_to @user
    # a failed update due to an invalid password 
    else
      render 'edit'
    end
  end



  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # email is automatically available in the edit action because of its presence in the reset link
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # Confirms a valid user
  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # Checks expiration of reset token
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end

end
