class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if !user&.activated? && user&.authenticated?(:activation, params[:id])
      user.activate
      set_log_in_session(user)
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end
end
