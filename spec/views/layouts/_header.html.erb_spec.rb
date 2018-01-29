require 'rails_helper'

RSpec.describe "layouts/_header", type: :view do
  describe 'render html' do
    it 'displays link' do
      render
      expect(rendered).to have_link href: '/', count: 2
      expect(rendered).to have_link 'Help', href: '/help'
      expect(rendered).to have_selector('a#logo')
    end
  end

  describe 'when logged_in? returns true' do
    let(:logged_in_true) do
      allow(view).to receive(:logged_in?).and_return(true)
      allow(view).to receive(:current_user).and_return(create(:user))
    end

    it 'renders dropdown partial' do
      logged_in_true
      render
      expect(rendered).to render_template partial: 'layouts/_dropdown'
    end
  end

  describe 'when logged_in? returns false' do
    let(:logged_in_false) do
      allow(view).to receive(:logged_in?).and_return(false)
    end

    it 'renders login link' do
      logged_in_false
      render
      expect(rendered).to have_link 'Log in', href: '/login'
    end
  end
end
