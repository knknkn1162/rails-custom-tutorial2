require 'rails_helper'

RSpec.describe 'sessions/new.html.erb', type: :view do
  before(:each) do
    render template: 'sessions/new', layout: layout
  end

  # default
  let(:layout) { false }

  context 'renders layouts' do
    let(:layout) { 'layouts/application' }
    it 'displays img and user_name' do
      expect(rendered).to have_title(/Log in/)
    end
  end

  context 'displays html' do
    it 'displays input' do
      expect(rendered).to have_selector('input[type=email][name="session[email]"]')
      expect(rendered).to have_selector('input[type=password][name="session[password]"]')
    end
    it 'displays button' do
      expect(rendered).to have_button(value: 'Log in')
      expect(rendered).to have_button(count: 1)
    end

    it 'displays checkbox' do
      expect(rendered).to have_unchecked_field
    end

    it 'displays link' do
      expect(rendered).to have_link href: '/signup'
      expect(rendered).to have_link href: '/password_resets/new'
    end
  end
end
