require 'rails_helper'

RSpec.describe 'users/_form', type: :view do
  before(:each) do
    render 'users/form', model: build(:user), button_text: button_text
  end

  let(:button_text) { 'Sample text' }

  it 'displays input' do
    expect(rendered).to have_selector('input[type=email][name="user[email]"]')
    expect(rendered).to have_selector('input[type=text][name="user[name]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password_confirmation]"]')
  end

  it 'displays button' do
    expect(rendered).to have_button(value: button_text)
    expect(rendered).to have_button(count: 1)
  end

  it 'renders _error_messages partial' do
    expect(rendered).to render_template('shared/_error_messages')
  end
end
