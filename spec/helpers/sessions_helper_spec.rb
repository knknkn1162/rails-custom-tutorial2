require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  describe 'log_in test' do
    it 'tests login' do
      user = instance_double('User', id: 10)
      helper.log_in(user)
      expect(session[:user_id]).to eq 10
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
