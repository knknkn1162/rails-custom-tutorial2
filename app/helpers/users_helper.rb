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
end
