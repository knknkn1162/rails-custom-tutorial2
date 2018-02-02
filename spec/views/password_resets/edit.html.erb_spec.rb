require 'rails_helper'

RSpec.describe 'password_resets/edit.html.erb', type: :view do
  before(:each) do
    assign(:user, build(:user))
    assign(:token_id, 'sample_token')
  end
  it 'displays title' do
    render template: 'password_resets/edit', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Reset password')
  end

  it 'renders form partial' do
    render
    expect(rendered).to render_template partial: 'shared/_error_messages'
  end

  it 'renders input' do
    render
    expect(rendered).to have_selector('input[type=password][name="user[password]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password_confirmation]"]')
  end

  it 'renders button' do
    render
    expect(rendered).to have_button(value: 'Update password')
    expect(rendered).to have_button(count: 1)
  end
end
