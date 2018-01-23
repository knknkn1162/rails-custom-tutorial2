require 'rails_helper'

RSpec.describe "static_pages/help.html.erb", type: :view do
  it 'displays title' do
    render template: 'static_pages/help', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Help')
  end
end
