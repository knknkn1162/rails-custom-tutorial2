require 'rails_helper'

RSpec.describe 'shared/_feed', type: :view do
  let(:user) do
    create(:user_with_microposts, microposts_count: 6)
  end

  before(:each) do
    inject_feed_items
    render
  end

  let(:inject_feed_items) do
    assign(:feed_items, user.microposts.paginate(page: page, per_page: per_page))
  end
  let(:per_page) { 5 }
  # default
  let(:page) { 1 }

  describe 'when feed_items doesnt exists' do
    let(:page) { 3 }
    it 'has no content when no feed_items' do
      expect(rendered).to eq ''
    end
  end

  describe 'when feed_items exists' do
    it 'renders partial' do
      expect(rendered).to render_template('microposts/_micropost')
    end

    it 'exists paginate' do
      expect(rendered).to have_selector('div.pagination')
    end

    it 'has 30 feed_items' do
      expect(rendered).to have_selector('ol.microposts li', count: per_page)
    end
  end
end
