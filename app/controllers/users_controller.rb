class UsersController < ApplicationController

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

  private 
    #use extra indentation for private methods
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
