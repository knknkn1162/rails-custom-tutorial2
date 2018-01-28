require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  describe 'test gravatar_for' do
    it 'returns img tag' do
      user = build(:user)
      expect(
        helper.gravatar_for(user.name, user.email)
      ).to have_selector 'img', class: 'gravatar'
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
