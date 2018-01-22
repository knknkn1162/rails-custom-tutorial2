require 'rails_helper'

RSpec.describe "layouts/_header", type: :view do
  it 'displays link' do
    render
    expect(rendered).to have_link 'Home'
    expect(rendered).to have_link 'Help'
    expect(rendered).to have_link 'Log in'
    expect(rendered).to have_selector('a#logo')
  end
end
