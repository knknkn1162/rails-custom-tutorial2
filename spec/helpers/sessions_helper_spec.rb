require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe 'log_in test' do
    it 'tests login' do
      user = instance_double('User', id: 10)
      helper.log_in(user)
      expect(session[:user_id]).to eq 10
    end
  end

  describe 'current_user test' do
    it 'tests current_user' do
      user = create(:user)
      session[:user_id] = user.id
      helper.current_user
      # TODO: unavailable to use assigns method after adding `rails-controller-testing` gem
      current_user = helper.instance_variable_get(:@current_user)
      expect(current_user).to eq user
    end
  end

  describe 'logged_in? test' do
    it 'should be true when log_in' do
      user = create(:user)
      session[:user_id] = user.id
      expect(helper.logged_in?).to be_truthy
    end
    it 'should be false when not log_in' do
      session[:user_id] = -1
      expect(helper.logged_in?).to be_falsy
    end
  end

  describe 'log_out test' do
    it 'should work' do
      user = create(:user)
      session[:user_id] = user.id
      helper.current_user
      helper.log_out

      expect(helper.instance_variable_get(:@current_user)).not_to be
      expect(session).to be_empty
    end
  end

  describe 'remember test' do
    let(:user) { create(:user) }
    before(:each) do
      remember user
    end
    it 'contains remember_token & remember_digest' do
      expect(user.remember_token).to be
      expect(user.remember_digest).to be
    end

    it 'contains cookies' do
      expect(cookies.signed[:user_id]).to be user.id
      expect(cookies[:remember_token]).to be user.remember_token
    end
  end
end
