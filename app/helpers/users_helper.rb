module UsersHelper
  def gravatar_for(name, email, size: 80)
    gravatar_id = Digest::MD5::hexdigest(email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: name, class: 'gravatar')
  end

  def generate_digest(string, cost: cost)
    BCrypt::Password.create(string, cost: cost)
  end

  def generate_token
    SecureRandom.urlsafe_base64
  end

  def get_user(user_id)
    User.find_by(id: user_id)
  end

  # REVIEW: how to deal with cookies? Should not be contains any method in helper module due to rspec test?
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

  # REVIEW: how to test the method dependent on current_user?
  def logged_in?
    !current_user.nil?
  end
end
