require 'rails_helper'

RSpec.describe "password_resets/new.html.erb", type: :view do
  context 'renders layouts' do
    it 'displays img and user_name' do
      render template: 'password_resets/new', layout: 'layouts/application'
      expect(rendered).to have_title full_title('Forget password')
    end
  end

  context 'displays html' do
    before(:each) { render }
    it 'displays input' do
      expect(rendered).to have_selector('input[type=email][name="password_reset[email]"]')
    end

    it 'displays button' do
      expect(rendered).to have_button(value: 'Submit', count: 1)
      #expect(rendered).to have_button(count: 1)
    end
  end
end
