class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  include UsersHelper
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created'
      redirect_to root_url
    else
      render 'static_pages/home'
    end
  end

  def destroy
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end

  def logged_in_user
    unless logged_in?
      # TODO: actually request.get? is required, but I don't understand why.
      store_location(request.original_url)
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end
end
