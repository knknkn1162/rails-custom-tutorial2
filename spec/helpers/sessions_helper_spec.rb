require 'rails_helper'

RSpec.describe SessionsHelper, type: :helper do
  let(:forwarding_url) { '/dummy' }
  let(:user_id) { 100 }

  describe 'set_log_in_session' do
    let(:user) { create(:user) }
    before(:each) do
      set_log_in_session(user)
    end
    it 'sets user_id hash' do
      expect(session[:user_id]).to eq user.id
    end
  end

  describe 'get_log_in_session' do
    before(:each) do
      session[:user_id] = user_id
    end
    it 'gets user_id hash' do
      expect(get_log_in_session).to eq user_id
    end
  end

  describe 'forget_log_in_session' do
    let(:user_id) { 100 }
    before(:each) do
      session[:user_id] = user_id
      forget_log_in_session
    end
    it 'deletes user_id hash' do
      expect(session).to be_empty
    end
  end

  describe 'store_location' do
    before(:each) do
      store_location('/dummy')
    end
    it 'stores forwaring_url hash' do
      expect(session[:forwarding_url]).to eq '/dummy'
    end
  end

  describe 'get_location test' do
    before(:each) do
      session[:forwarding_url] = forwarding_url
    end
    it 'gets forwarding_url hash' do
      expect(get_location).to eq forwarding_url
    end
  end

  describe 'delete_location test' do
    before(:each) do
      session[:forwarding_url] = forwarding_url
      delete_location
    end
    it 'deletes forwarding_url hash' do
      expect(session).to be_empty
    end
  end
end
