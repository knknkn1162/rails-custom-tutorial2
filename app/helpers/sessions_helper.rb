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

  def store_location(url)
    session[:forwarding_url] = url
  end

  def get_location
    session[:forwarding_url]
  end

  def delete_location
    session.delete(:forwarding_url)
  end
end
