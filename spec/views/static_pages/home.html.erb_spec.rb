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
    let(:stubbed_current_user) do
      stubbed_logged_in
      allow(view).to receive(:current_user).and_return(create(:user))
    end

    before(:each) do
      stubbed_current_user
      assign(:micropost, Micropost.new)
      render
    end
    it 'renders _log_in_home' do
      expect(rendered).to render_template('static_pages/_login_home')
    end
  end
end
