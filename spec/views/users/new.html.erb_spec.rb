require 'rails_helper'

RSpec.describe 'users/new.html.erb', type: :view do
  it 'displays title' do
    render template: 'users/new', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Sign up')
  end
end