class UsersController < ApplicationController
  include UsersHelper
  before_action :logged_in_user, only: %i[edit update]
  before_action :correct_user, only: %i[edit update]
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Welcome to the Sample App'
      # same as user_url(@user)
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  # REVIEW: Is there any way to test the method directly?
  # currently, cope with Anonymous controller via before_action.
  def logged_in_user
    unless logged_in?
      # TODO: actually request.get? is required, but I don't understand why.
      store_location(request.original_url)
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
