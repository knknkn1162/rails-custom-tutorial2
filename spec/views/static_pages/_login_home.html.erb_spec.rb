require 'rails_helper'

RSpec.describe 'static_pages/_login_home', type: :view do
  before(:each) do
    inject_feed_items
    inject_micropost
    stubbed_current_user
    render
  end

  let(:user) do
    create(:user_with_microposts, microposts_count: per_page)
  end

  # instance variable injection
  let(:inject_feed_items) do
    assign(:feed_items, user.microposts.paginate(page: 1, per_page: per_page))
  end

  let(:inject_micropost) do
    assign(:micropost, Micropost.new)
  end

  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(current_user_flag)
  end

  # default
  let!(:current_user_flag) { user }
  let(:per_page) { 5 }

  it 'has partial pages' do
    ['shared/_user_info', 'shared/_micropost_form', 'shared/_feed'].each do |partial|
      expect(rendered).to render_template(partial)
    end
  end

  it 'has Micropost feed content' do
    expect(rendered).to match(/Micropost feed/i)
  end
end
