require 'rails_helper'

RSpec.describe 'layouts/_header', type: :view do
  let(:stubbed_logged_in?) do
    allow(view).to receive(:logged_in?).and_return(logged_in_flag)
    allow(view).to receive(:current_user).and_return(create(:user))
  end

  before(:each) do
    stubbed_logged_in?
    render
  end

  # default
  let(:logged_in_flag) { false }

  context 'render html' do
    it 'displays link' do
      expect(rendered).to have_link href: '/', count: 2
      expect(rendered).to have_link('Help', href: '/help')
      expect(rendered).to have_selector('a#logo')
    end
  end

  context 'when logged_in? returns false' do
    it 'renders login link' do
      expect(rendered).to have_link 'Log in', href: '/login'
    end
  end

  context 'when logged_in? returns true' do
    let(:logged_in_flag) { true }
    it 'renders dropdown partial' do
      expect(rendered).to render_template partial: 'layouts/_dropdown'
    end
  end
end
