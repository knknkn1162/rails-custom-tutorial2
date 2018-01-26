class User < ApplicationRecord
  include UsersHelper
  attr_accessor :remember_token
  before_save :downcase_email
  validates :name,
    presence: true,
    length: { maximum: 50 }
  validates :email,
    presence: true,
    length: { maximum: 255 },
    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
    uniqueness: { case_sensitive: false }
  validates :password,
    presence: true,
    length: { minimum: 6 }

  # you can use password & password_confirmation attribute
  # and authenticate method
  has_secure_password

  def remember
    self.remember_token = generate_token
    update_attribute(:remember_digest, generate_digest(remember_token))
  end

  def authenticated?(remember_token)
    remember_digest ? BCrypt::Password.new(remember_digest).is_password?(remember_token) : false
  end

  private

  def downcase_email
    email.downcase!
  end
end
