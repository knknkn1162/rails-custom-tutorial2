require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  let(:user) { create(:user) }
  describe 'gravatar_for' do
    it 'returns img tag' do
      expect(
        helper.gravatar_for(user.name, user.email)
      ).to have_selector 'img', class: 'gravatar'
    end
  end

  describe 'get_user' do
    it 'contains session' do
      u = helper.get_user(user.id)
      expect(u).to eq user
    end
  end

  describe 'logged_in?' do
    before(:each) do
      expect(helper).to receive(:current_user).and_return(user)
    end
    it 'checks logged_in' do
      expect(helper.logged_in?).to be_truthy
    end
  end
end
