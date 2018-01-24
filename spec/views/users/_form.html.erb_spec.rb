require 'rails_helper'

RSpec.describe "users/_form", type: :view do
  it 'displays title' do
    render partial: 'users/form', locals: { model: build(:user) }

    expect(rendered).to have_selector('input[type=email][name="user[email]"]')
    expect(rendered).to have_selector('input[type=text][name="user[name]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password_confirmation]"]')

    expect(rendered).to have_button(value: 'Create my account')
    expect(rendered).to have_button(count: 1)
  end
end
