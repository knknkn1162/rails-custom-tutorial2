require 'rails_helper'

RSpec.describe 'users/_user', type: :view do
  let(:user) { create(:user) }
  let(:current_user_false) do
    allow(view).to receive(:current_user?).and_return(false)
  end

  it 'renders link and img' do
    render 'users/user', user: user
    expect(rendered).to have_selector('img.gravatar')
    expect(rendered).to have_link(href: "/users/#{user.id}", text: user.name)
  end

  describe 'when admin user' do
    it 'renders delete link' do
      current_user_false
      render 'users/user', user: user
      expect(rendered).to have_link(
        href: "/users/#{user.id}",
        text: 'delete'
      )
    end
  end

  describe 'when non-admin user' do
    let(:other) { create(:other) }
    let(:current_user_true) do
      allow(view).to receive(:current_user?).and_return(true)
    end

    it 'doesnt exist delete link' do
      current_user_true
      render 'users/user', user: other
      expect(rendered).not_to have_link(text: 'delete')
    end
  end
end
