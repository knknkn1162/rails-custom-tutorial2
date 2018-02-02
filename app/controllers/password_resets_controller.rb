class PasswordResetsController < ApplicationController
  before_action :get_user_with_validation, only: %i[edit update]

  def new
  end

  def edit
    get_user unless @user
    @user.reset_token = params[:id]
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new'
    end
  end

  def update
  end

  private
  def get_user
    @user = User.find_by(email: params[:email])
  end

  def get_user_with_validation
    get_user
    unless (@user&.activated? && @user&.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end
end
