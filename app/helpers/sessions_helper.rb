module SessionsHelper
  def set_log_in_session(user)
    session[:user_id] = user.id
  end

  def get_log_in_session
    session[:user_id]
  end

  def forget_log_in_session
    session.delete(:user_id)
  end
end
