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

  context 'renders users/show only' do
    before(:each) do
      user = build(:user)
      assign(:user, user)
    end

    it 'displays img and user_name' do
      user = build(:user)
      render
      expect(rendered).to have_selector("img[alt='#{user.name}']",
                                        class: 'gravatar')
      expect(rendered).to have_content(user.name)
    end
  end
end
