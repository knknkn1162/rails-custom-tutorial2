module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  # TODO: how to deal with cookies? Should not be contains any method in helper module due to rspec test?
  def get_user(user_id)
    User.find_by(id: user_id)
  end
end
