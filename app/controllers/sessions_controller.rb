class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)

    if user #user&.authenticate(params[:session][:password])
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end
end
