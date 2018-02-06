require 'rails_helper'

RSpec.describe 'password_resets/edit.html.erb', type: :view do
  before(:each) do
    inject_user
    render template: 'password_resets/edit', layout: layout
  end

  let(:inject_user) do
    assign(:user, build(:user, reset_token: 'sample_token'))
  end

  # default
  let(:layout) { false }

  context 'when renders layout' do
    let(:layout) { 'layouts/application' }
    it 'displays title' do
      expect(rendered).to have_title full_title('Reset password')
    end
  end

  it 'renders form partial' do
    expect(rendered).to render_template partial: 'shared/_error_messages'
  end

  it 'renders input' do
    expect(rendered).to have_selector('input[type=password][name="user[password]"]')
    expect(rendered).to have_selector('input[type=password][name="user[password_confirmation]"]')
  end

  it 'renders button' do
    expect(rendered).to have_button(value: 'Update password')
    expect(rendered).to have_button(count: 1)
  end
end
