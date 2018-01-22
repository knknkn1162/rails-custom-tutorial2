require 'rails_helper'

RSpec.describe "static_pages/home.html.erb", type: :view do
  it 'displays title' do
    render template: 'static_pages/home', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Home')
  end
end
