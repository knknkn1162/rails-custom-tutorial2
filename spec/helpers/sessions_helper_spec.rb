require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe 'set_log_in_session test' do
    it 'tests set_log_in' do
      user = instance_double('User', id: 10)
      set_log_in_session(user)
      expect(session[:user_id]).to eq 10
    end
  end

  describe 'get_log_in_session test' do
    it 'tests get_log_in' do
      session[:user_id] = 100
      expect(get_log_in_session).to eq 100
    end
  end

  describe 'forget_log_in_session test' do
    it 'tests forget_log_in_session' do
      session[:user_id] = 100
      forget_log_in_session
      expect(session).to be_empty
    end
  end

  describe 'store_location test' do
    it 'succeeds' do
      store_location('/dummy')
      expect(session[:forwarding_url]).to eq '/dummy'
    end
  end

  describe 'get_location test' do
    it 'succeeds' do
      session[:forwarding_url] = 'dummy'
      expect(get_location).to eq 'dummy'
    end
  end

  describe 'delete_location test' do
    it 'succeeds' do
      session[:forwarding_url] = 'dummy'
      delete_location
      expect(session).to be_empty
    end
  end
end
