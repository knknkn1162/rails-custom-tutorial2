require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'renders with layout' do
    before(:each) do
      user = build(:user)
      assign(:user, user)
    end

    it 'displays title' do
      render template: 'users/show', layout: 'layouts/application'
      expect(rendered).to have_title full_title(build(:user).name)
    end
  end
end
