require 'rails_helper'

RSpec.describe "layouts/_header", type: :view do
  it 'displays link' do
    render
    expect(rendered).to have_link href: '/', count: 2
    expect(rendered).to have_link 'Help', href: '/help'
    expect(rendered).to have_link 'Log in', href: '#'
    expect(rendered).to have_selector('a#logo')
  end
end
