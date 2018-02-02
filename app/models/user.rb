class User < ApplicationRecord
  include UsersHelper
  has_many :microposts
  attr_accessor :remember_token, :activation_token, :reset_token
  # calls when create or update
  before_save :downcase_email
  # calls when create only
  before_create :create_activation_digest

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
    length: { minimum: 6 },
    allow_nil: true

  # you can use password & password_confirmation attribute
  # and authenticate method
  has_secure_password

  def remember
    self.remember_token = generate_token
    update_attribute(:remember_digest, generate_digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attributes(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = generate_token
    update_attributes(
      reset_digest: generate_digest(reset_token),
      reset_sent_at: Time.zone.now
    )
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def authenticated?(attr, token)
    digest = send("#{attr}_digest")
    digest.nil? ? false : BCrypt::Password.new(digest).is_password?(token)
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = generate_token
    self.activation_digest = generate_digest(activation_token)
  end

end
