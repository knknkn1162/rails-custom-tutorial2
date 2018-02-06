require 'rails_helper'

RSpec.describe "static_pages/help.html.erb", type: :view do
  before(:each) do
    render template: 'static_pages/help', layout: 'layouts/application'
  end
  it 'displays title' do
    expect(rendered).to have_title(/Help/)
  end
end
