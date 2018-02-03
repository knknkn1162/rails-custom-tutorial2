require 'rails_helper'

RSpec.describe "microposts/_micropost", type: :view do
  let(:user) { create(:user) }
  let(:micropost) { create(:micropost, user: user) }
  before(:each) do
    render 'microposts/micropost', micropost: micropost
  end
  it 'renders li' do
    expect(rendered).to have_selector("li.micropost-#{micropost.id}")
  end

  it 'renders user link' do
    expect(rendered).to have_link(href: "/users/#{user.id}", text: user.name)
  end

  it 'renders content' do
    expect(rendered).to have_content(micropost.content)
  end

  it 'renders timestamp' do
    expect(rendered).to match /Posted .* ago./
  end
end
