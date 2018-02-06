require 'rails_helper'

RSpec.describe 'static_pages/contact', type: :view do
  before(:each) do
    render template: 'static_pages/contact', layout: layout
  end

  # default
  let(:layout) { false }

  context 'renders with layout' do
    let(:layout) { 'layouts/application' }
    it 'renders correct title' do
      expect(rendered).to have_title(/Contact/)
    end
  end

  context 'renders no layouts' do
    it 'displays contact_page' do
      expect(rendered).to have_link href: /contact/
    end
  end
end
