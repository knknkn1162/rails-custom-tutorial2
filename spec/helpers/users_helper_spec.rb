require 'rails_helper'

RSpec.describe UsersHelper, type: :helper do
  describe 'test gravatar_for' do
    it 'returns img tag' do
      user = build(:user)
      expect(helper.gravatar_for(user)).to have_selector 'img', class: 'gravatar'
    end
  end
end
