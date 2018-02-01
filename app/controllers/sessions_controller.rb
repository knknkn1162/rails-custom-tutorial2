class SessionsController < ApplicationController
  include UsersHelper

  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      if @user.activated?
        set_log_in_session @user
        params[:session][:remember_me] == '1' ? remember : forget
        # friendly forwarding
        redirect_to(get_location || @user)
        delete_location
      else
        message = 'Account not activated'
        message += 'Check your email for the activation link'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    @user = current_user
    forget || forget_log_in_session if @user
    redirect_to root_url
  end

  # REVIEW: Doesn't this method have to be tested in spec/contorollers?
  private

  def remember
    @user.remember
    # :foo and "foo" are different keys in controller spec. To avoid inconsistancy, we use string keys
    # see also, `Why not use the cookies method?` section in https://relishapp.com/rspec/rspec-rails/docs/controller-specs/cookies.
    cookies.permanent.signed['user_id'] = @user.id
    cookies.permanent['remember_token'] = @user.remember_token
  end

  def forget
    @user.forget
    cookies.delete('user_id')
    cookies.delete('remember_token')
  end
end
