require 'rails_helper'

RSpec.describe 'users/_user', type: :view do
  before(:each) do
    stubbed_current_user
    render 'users/user', user: local_user
  end

  let(:user) { create(:user) }
  let(:other) { create(:other) }

  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(current_user_flag)
  end

  # default
  let(:current_user_flag) { user }
  let(:local_user) { user }

  # expr
  let(:have_user_delete_link) do
    have_link(href: "/users/#{user.id}", text: 'delete')
  end
  let(:have_other_delete_link) do
    have_link(href: "/users/#{other.id}", text: 'delete')
  end

  it 'renders link and img' do
    expect(rendered).to have_selector('img.gravatar')
    expect(rendered).to have_link(href: "/users/#{user.id}", text: user.name)
  end

  context 'when current_user is user' do
    let(:local_user) { other }
    it 'renders others delete link' do
      expect(rendered).to have_other_delete_link
    end

    it 'doesnt render users delete link' do
      expect(rendered).not_to have_user_delete_link
    end
  end

  context 'when current_user is other' do
    let(:current_user_flag) { other }
    it 'renders delelte link' do
      expect(rendered).not_to have_other_delete_link
      expect(rendered).not_to have_user_delete_link
    end
  end
end
