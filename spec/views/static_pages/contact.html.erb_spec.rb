require 'rails_helper'

RSpec.describe "static_pages/contact", type: :view do
  it 'displays title' do
    render template: 'static_pages/contact', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Contact')
  end

  it 'displays contact_page' do
    render
    expect(rendered).to have_link href: 'https://railstutorial.jp/contact'
  end
end
