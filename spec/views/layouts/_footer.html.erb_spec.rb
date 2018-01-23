require 'rails_helper'

RSpec.describe 'layouts/_footer', type: :view do
  it 'displays nav link' do
    render
    expect(rendered).to have_link 'About', href: '/about'
    expect(rendered).to have_link 'Contact', href: '/contact'
    expect(rendered).to have_link 'News'
  end
end
