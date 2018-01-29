require 'rails_helper'

RSpec.describe 'layouts/_dropdown', type: :view do
  let(:user) { create(:user) }
  before(:each) do
    render 'layouts/dropdown', user: user
  end

  it 'displays dropdown and implements toggle' do
    expect(rendered).to have_selector('li.dropdown')
    expect(rendered).to have_link(class: 'dropdown-toggle')
  end

  it 'displays dropdown-menu and its list' do
    expect(rendered).to have_selector('ul.dropdown-menu')
    expect(rendered).to have_selector(
      "ul.dropdown-menu a[href='/users/#{user.id}']",
      text: 'Profile'
    )
    expect(rendered).to have_selector(
      "ul.dropdown-menu a[href='/users/#{user.id}/edit']",
      text: 'Settings'
    )
    expect(rendered).to have_selector(
      "ul.dropdown-menu a[href='/logout']",
      text: 'Log out'
    )
  end
end
