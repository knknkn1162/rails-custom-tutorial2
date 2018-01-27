class SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password])
      log_in @user
      @user.remember
      # :foo and "foo" are different keys in controller spec. To avoid inconsistancy, we use string keys
      # see also, `Why not use the cookies method?` section in https://relishapp.com/rspec/rspec-rails/docs/controller-specs/cookies.
      cookies.permanent.signed['user_id'] = @user.id
      cookies.permanent['remember_token'] = @user.remember_token
      redirect_to @user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
