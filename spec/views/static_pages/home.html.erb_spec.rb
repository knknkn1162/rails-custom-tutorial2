require 'rails_helper'

RSpec.describe 'static_pages/home.html.erb', type: :view do
  let(:stubbed_logged_in) do
    allow(view).to receive(:logged_in?).and_return(logged_in_flag)
  end

  # default
  let(:logged_in_flag) { false }
  describe 'when not logged in' do
    before(:each) do
      stubbed_logged_in
    end

    it 'displays title' do
      render template: 'static_pages/home', layout: 'layouts/application'
      expect(rendered).to have_title full_title('Home')
    end

    it 'displays sign up now' do
      render
      expect(rendered).to have_link href: '/signup'
    end
  end

  describe 'when logged in' do
    let(:logged_in_flag) { true }
    let(:user) do
      create(:user_with_microposts, microposts_count: 6)
    end

    let(:stubbed_current_user) do
      stubbed_logged_in
      allow(view).to receive(:current_user).and_return(user)
    end

    # instance variable injection
    let(:inject_feed_items) do
      assign(:feed_items, user.microposts.paginate(page: 1, per_page: 5))
    end

    let(:inject_micropost) do
      assign(:micropost, Micropost.new)
    end

    before(:each) do
      inject_feed_items
      inject_micropost
      stubbed_current_user
      stubbed_logged_in
      render
    end
    it 'renders _log_in_home' do
      expect(rendered).to render_template('static_pages/_login_home')
    end
  end
end
