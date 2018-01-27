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

  describe 'get_user test' do
    let(:user) { create(:user) }
    it 'contains session' do
      u = helper.get_user(user.id)
      expect(u).to eq user
    end
  end
end
