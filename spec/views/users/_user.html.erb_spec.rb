require 'rails_helper'

RSpec.describe 'users/_user', type: :view do
  let(:user) { create(:user) }
  it 'renders ' do
    render 'users/user', user: user
    expect(rendered).to have_selector('img.gravatar')
    expect(rendered).to have_link(href: "/users/#{user.id}", text: user.name)
  end
end
