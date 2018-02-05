require 'rails_helper'

RSpec.describe 'static_pages/home.html.erb', type: :view do
  let(:stubbed_logged_in) do
    allow(view).to receive(:logged_in?).and_return(logged_in_flag)
  end

  # default
  let(:logged_in_flag) { false }
  describe 'when not logged in' do
    it 'displays title' do
      render template: 'static_pages/home', layout: 'layouts/application'
      expect(rendered).to have_title full_title('Home')
    end

    it 'displays sign up now' do
      render
      expect(rendered).to have_link href: '/signup'
    end
  end
end
