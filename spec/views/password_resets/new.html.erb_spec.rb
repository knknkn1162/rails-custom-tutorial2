require 'rails_helper'

RSpec.describe 'password_resets/new.html.erb', type: :view do
  before(:each) do
    render template: 'password_resets/new', layout: layout
  end
  let(:layout) { false }

  context 'renders layouts' do
    let(:layout) { 'layouts/application' }
    it 'displays img and user_name' do
      render template: 'password_resets/new', layout: 'layouts/application'
      expect(rendered).to have_title(/Forget password/)
    end
  end

  context 'displays html' do
    it 'displays input' do
      expect(rendered).to have_selector('input[type=email][name="password_reset[email]"]')
    end

    it 'displays button' do
      expect(rendered).to have_button(value: 'Submit', count: 1)
      expect(rendered).to have_button(count: 1)
    end
  end
end
