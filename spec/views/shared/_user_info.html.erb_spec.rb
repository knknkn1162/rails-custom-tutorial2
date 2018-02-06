require 'rails_helper'

RSpec.describe 'shared/_user_info', type: :view do
  before(:each) do
    stubbed_current_user
    render 'shared/user_info'
  end

  let(:user) do
    create(:user_with_microposts, microposts_count: microposts_count)
  end

  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(user)
  end

  # default
  let(:microposts_count) { 5 }

  it 'has gravatar link' do
    expect(rendered).to have_link(href: "/users/#{user.id}", count: 2)
    expect(rendered).to have_selector('a img.gravatar')

    expect(rendered).to include "#{user.name}"
    expect(rendered).to include "#{microposts_count} microposts"
  end
end
