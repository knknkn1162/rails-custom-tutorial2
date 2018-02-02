require 'rails_helper'

RSpec.describe User, type: :model do

  describe 'when validation check' do
    context 'when invalid name contains' do
      it 'should be non-empty name' do
        user = build(:user, name: ' ')
        expect(user).not_to be_valid
      end

      it 'should not be long name' do
        user = build(:user, name: 'a' * 51)
        expect(user).not_to be_valid
      end
    end

    context 'when the invalid email contains' do
      it 'should be non-empty email' do
        user = build(:user, email: ' ')
        expect(user).not_to be_valid
      end

      it 'should not be long email' do
        suffix = '@example.com'
        user = build(:user, email: 'a' * (256 - suffix.length) + suffix)
        expect(user).not_to be_valid
      end

      it 'should be email-formatted' do
        %w[user@example,com
          user_at_foo.org
          user.name@example.foo@bar_baz.com
          foo@bar+baz.com].each do |address|
          user = build(:user, email: address)
          expect(user).not_to be_valid
        end
      end

      it 'should be unique email' do
        create(:user)
        duplicated_user = build(:user)
        expect(duplicated_user).not_to be_valid
      end
    end

    context 'when the invalid password contains' do
      it 'should be present(nonblank) password' do
        user = build(:user, password: ' ' * 6)
        expect(user).not_to be_valid
      end

      it 'should be at least 6 characters' do
        invalid_password = 'a' * 5
        user = build(:user, password: invalid_password, password_confirmation: 5)
        expect(user).not_to be_valid
      end
    end

    context 'when the valid email contains' do
      it 'should be email-formatted' do
        %w[user@example.com
          USER@foo.COM
          A_US-ER@foo.bar.org
          first.last@foo.jp
          alice+bob@baz.cn].each do |address|
          user = build(:user, email: address)
          expect(user).to be_valid
        end
      end
    end
  end

  describe 'when public method calls' do
    include UsersHelper
    it 'tests remember method' do
      user = build(:user)
      user.remember
      expect(user.remember_token).to be
      expect(
        BCrypt::Password.new(user.remember_digest)
      ).to eq user.remember_token
    end

    context 'tests authenticated? method' do
      it 'fails when not remembered' do
        user = build(:user)
        expect(user.authenticated?(:remember, nil)).to be_falsy
      end

      it 'successes when puts remember_token' do
        user = build(:user)
        user.remember_token = 'sample'
        user.remember_digest = generate_digest('sample')
        expect(user.authenticated?(:remember, 'sample')).to be_truthy
      end

      it 'successes when puts activation_token & activation_digest' do
        user = build(:user)
        user.activation_token = 'sample'
        user.activation_digest = generate_digest('sample')
        expect(user.authenticated?(:activation, 'sample')).to be_truthy
      end
    end

    context 'when forget method' do
      it 'clear remember_digest' do
        user = build(:user, remember_digest: 'sample')
        user.forget
        expect(user.remember_digest).not_to be
      end
    end

    context 'when activate method' do
      it 'success' do
        user = build(:user, activated: false)
        user.activate
        expect(user.activate).to be_truthy
        expect(user.activated_at).to be
      end
    end

    context 'create_reset_digest' do
      it 'success' do
        user = build(:user)
        user.create_reset_digest
        expect(user.reset_token).to be
        expect(user.reset_digest).to be
        expect(user.reset_sent_at).to be
      end
    end

    context 'when send_activation_email' do
      it 'success' do
        user = create(:user)
        expect do
          user.send_activation_email
        end.to change{ ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when send_password_reset_email' do
      it 'success' do
        user = create(:user, reset_token: 'sample_token')
        expect do
          user.send_password_reset_email
        end.to change{ ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when password_reset_expired?' do
      it 'not expired (false)' do
        user = create(:user, reset_sent_at: Time.zone.now)
        expect(user.password_reset_expired?).to be_falsy
      end

      it 'expired (true)' do
        user = create(:user, reset_sent_at: 3.hours.ago)
        expect(user.password_reset_expired?).to be_truthy
      end
    end
  end

  describe 'when private method calls' do
    it 'downcases email' do
      user = build(:user, email: 'Foo@ExAmPLe.COm')
      user.send(:downcase_email)
      expect(user.email).to eq 'foo@example.com'
    end

    it 'creates activation_digest' do
      user = build(:user)
      user.send(:create_activation_digest)
      expect(user.activation_token).to be
      expect(user.activation_digest).to be
    end
  end

  # The way to test callbacks is the link below:
  # https://stackoverflow.com/a/16678194/8774173
  # that is independent of the gem, https://github.com/jdliss/shoulda-callback-matchers
  describe 'when callbacks' do
    describe 'when downcase_email' do
      it 'calls before create' do
        user = build(:user)
        expect(user).to receive(:downcase_email)
        user.save
      end

      it 'calls before update' do
        user = create(:user)
        expect(user).to receive(:downcase_email)
        user.update_attribute(:email, 'uPDate@example.com')
      end
    end

    describe 'when create_activation_digest' do
      it 'calls before save' do
        user = build(:user)
        expect(user).to receive(:create_activation_digest)
        user.save
      end

      it 'doesnt call before update' do
        user = create(:user)
        expect(user).not_to receive(:create_activation_digest)
        user.update_attributes(name: 'other', email: 'uPDate@example.com')
      end
    end
  end
end
