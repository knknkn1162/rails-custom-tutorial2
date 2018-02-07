require 'rails_helper'

RSpec.describe User, type: :model do
  include UsersHelper
  context 'when validation check' do
    context 'when invalid name contains' do
      let(:user) { build(:user, name: name) }
      context 'when blank name' do
        let(:name) { ' ' }

        it { expect(user).not_to be_valid }
      end

      context 'when long name' do
        let(:name) { 'a' * 51 }

        it { expect(user).not_to be_valid }
      end
    end

    context 'when invalid email contains' do
      let(:user) { build(:user, email: email) }
      context 'when blank email' do
        let(:email) { ' ' }

        it { expect(user).not_to be_valid }
      end

      context 'when long email' do
        let(:suffix) { '@example.com' }
        let(:email) { 'a' * (256 - suffix.length) + suffix }

        it { expect(user).not_to be_valid }
      end

      context 'when email-ill-formatted' do
        let(:emails) do
          %w[user@example,com
            user_at_foo.org
            user.name@example.foo@bar_baz.com
            foo@bar+baz.com]
        end
        it do
          emails.each {|email| expect(build(:user, email: email)).not_to be_valid}
        end
      end

      context 'when email is duplicated' do
        before { create(:user) }
        let(:duplicated_user) { build(:user) }

        it { expect(duplicated_user).not_to be_valid }
      end
    end

    context 'when the valid email contains' do
      let(:emails) do
        %w[user@example.com
          USER@foo.COM
          A_US-ER@foo.bar.org
          first.last@foo.jp
          alice+bob@baz.cn]
      end
      it 'should be email-formatted' do
        emails.each { |email| expect(build(:user, email: email)).to be_valid }
      end
    end

    context 'when the invalid password contains' do
      let(:user) { build(:user, password: password, password_confirmation: password_confirmation) }
      let(:other) { build(:other) }

      # default
      let(:password) { other.password }
      let(:password_confirmation) { other.password_confirmation }
      context 'when blank password' do
        let(:password) { ' ' * 6 }
        let(:password_confirmation) { ' ' * 6 }

        it { expect(user).not_to be_valid }
      end

      context 'when at least 6 characters' do
        let(:password) { 'a' * 5 }
        let(:password_confirmation) { 'a' * 5 }

        it { expect(user).not_to be_valid }
      end

      context 'when password & password_confirmation is different' do
        let(:password_confirmation) { password + 'dummy' }

        it { expect(user).not_to be_valid }
      end
    end
  end

  context 'when association check' do
    let(:user) { create(:user_with_microposts) }
    let(:microposts_count) { user.microposts.count }
    it 'delete with post' do
      expect { user.destroy }.to change(Micropost, :count).by(-microposts_count)
    end
  end

  context 'when public method calls' do
    let(:user) { build(:user) }
    before { user.remember }
    it 'tests remember method' do
      expect(user.remember_token).to be
      expect(
        BCrypt::Password.new(user.remember_digest)
      ).to eq user.remember_token
    end

    context 'tests authenticated? method' do
      let(:token) { 'sample' }
      context 'when not remembered' do
        let(:token) { nil }
        it { expect(user.authenticated?(:remember, token)).to be_falsy }
      end

      context 'when puts remember_token & remember_digest' do
        before do
          user.remember_token = token
          user.remember_digest = generate_digest(token)
        end
        it do
          expect(user.authenticated?(:remember, token)).to be_truthy
        end
      end

      context 'when puts activation_token & activation_digest' do
        before do
          user.activation_token = token
          user.activation_digest = generate_digest(token)
        end
        it do
          expect(user.authenticated?(:activation, token)).to be_truthy
        end
      end
    end

    context 'when forget method' do
      let(:user) { build(:user, remember_digest: 'sample') }
      before { user.forget }
      it 'clear remember_digest' do
        expect(user.remember_digest).not_to be
      end
    end

    context 'when activate method' do
      let(:user) { build(:user, activated: false) }
      before { user.activate }
      it 'success' do
        expect(user.activated).to be_truthy
        expect(user.activated_at).to be
      end
    end

    context 'create_reset_digest' do
      let(:user) { build(:user) }
      before { user.create_reset_digest }
      it 'success' do
        expect(user.reset_token).to be
        expect(user.reset_digest).to be
        expect(user.reset_sent_at).to be
      end
    end

    context 'when send_activation_email' do
      let(:user) { create(:user) }
      it 'success' do
        expect do
          user.send_activation_email
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when send_password_reset_email' do
      let(:user) { create(:user, reset_token: 'sample_token') }
      it 'success' do
        expect do
          user.send_password_reset_email
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when password_reset_expired?' do
      let(:user) { create(:user, reset_sent_at: reset_sent_at) }
      context 'when not expired (false)' do
        let(:reset_sent_at) { Time.zone.now }

        it { expect(user.password_reset_expired?).to be_falsy }
      end

      context 'when expired (true)' do
        let(:reset_sent_at) { 3.hours.ago }

        it { expect(user.password_reset_expired?).to be_truthy }
      end
    end

    context 'when feed method' do
      before do
        create(:other) do |other|
          create_list(:micropost, 10, user: other)
        end
      end
      let(:user) { create(:user_with_microposts, microposts_count: 5) }

      it 'feeds correctly' do
        expect(user.feed).to eq user.microposts
      end
    end
  end

  describe 'private methods' do
    let(:user) { build(:user, email: 'Foo@ExAmPLe.COm') }
    describe 'downcase_email' do
      before { user.send(:downcase_email) }

      it { expect(user.email).to eq 'foo@example.com' }
    end

    describe 'create_activation_digest' do
      let(:user) { build(:user) }
      before { user.send(:create_activation_digest) }

      it 'contains action_token & activation_digest' do
        expect(user.activation_token).to be
        expect(user.activation_digest).to be
      end
    end
  end

  # The way to test callbacks is the link below:
  # https://stackoverflow.com/a/16678194/8774173
  # that is independent of the gem, https://github.com/jdliss/shoulda-callback-matchers
  context 'when callbacks' do
    describe 'downcase_email' do
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

    describe 'create_activation_digest' do
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
