require 'rails_helper'

RSpec.describe 'users/_user', type: :view do
  let(:user) { create(:user) }
  let(:other) { create(:other) }
  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(current_user_flag)
  end

  let(:current_user_ok) do
    # it indicates that current_user.admin equals true
    allow(view).to receive(:current_user).and_return(user)
  end

  it 'renders link and img' do
    current_user_ok
    render 'users/user', user: user
    expect(rendered).to have_selector('img.gravatar')
    expect(rendered).to have_link(href: "/users/#{user.id}", text: user.name)
  end

  describe 'when current_user is user' do
    let(:current_user_flag) { user }
    it 'renders others delete link' do
      stubbed_current_user
      render 'users/user', user: other
      expect(rendered).to have_link(
        href: "/users/#{other.id}",
        text: 'delete'
      )
    end

    it 'doesnt render users delete link' do
      stubbed_current_user
      render 'users/user', user: user
      expect(rendered).not_to have_link(
        href: "/users/#{user.id}",
        text: 'delete'
      )
    end
  end

  describe 'when current_user is other' do
    let(:current_user_flag) { other }
    it 'renders delelte link' do
      stubbed_current_user
      render 'users/user', user: other

      expect(rendered).not_to have_link(
        href: "/users/#{other.id}",
        text: 'delete'
      )
    end
  end
end
