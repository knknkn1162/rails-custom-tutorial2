require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do

  let(:user) { create(:user) }
  let(:current_my_user) do
    expect(helper).to receive(:current_user).and_return(user)
  end

  describe 'test gravatar_for' do
    it 'returns img tag' do
      user = build(:user)
      expect(
        helper.gravatar_for(user.name, user.email)
      ).to have_selector 'img', class: 'gravatar'
    end
  end

  describe 'get_user test' do
    it 'contains session' do
      u = helper.get_user(user.id)
      expect(u).to eq user
    end
  end
end
