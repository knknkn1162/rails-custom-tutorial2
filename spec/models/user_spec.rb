require 'rails_helper'

RSpec.describe User, type: :model do
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
