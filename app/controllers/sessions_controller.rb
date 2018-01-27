class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      set_log_in_session @user
      params[:session][:remember_me] == '1' ? remember : forget
      redirect_to @user
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

  def current_user
    user_id = get_log_in_session
    if user_id
      get_user(user_id)
    else
      user = get_user(cookies.signed['user_id'])
      if user&.authorized?(remember_token)
        set_log_in_session user
        user
      end
    end
  end

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
