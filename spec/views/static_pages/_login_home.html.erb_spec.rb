require 'rails_helper'

RSpec.describe 'static_pages/_login_home', type: :view do
  let(:user) do
    create(:user_with_microposts, microposts_count: 6)
  end

  # instance variable injection
  let(:inject_feed_items) do
    assign(:feed_items, user.microposts.paginate(page: 1, per_page: 5))
  end

  let(:inject_micropost) do
    assign(:micropost, Micropost.new)
  end

  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(user)
  end

  before(:each) do
    inject_feed_items
    inject_micropost
    stubbed_current_user
    render
  end

  it 'has partial pages' do
    expect(rendered).to render_template('shared/_user_info')
    expect(rendered).to render_template('shared/_micropost_form')
    expect(rendered).to render_template('shared/_feed')
  end

  it 'has Micropost feed content' do
    expect(rendered).to match /Micropost feed/i
  end
end
