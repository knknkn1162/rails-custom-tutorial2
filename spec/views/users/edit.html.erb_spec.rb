require 'rails_helper'

RSpec.describe 'users/edit', type: :view do
  before(:each) do
    inject_user
    render template: 'users/edit', layout: layout
  end

  let(:inject_user) do
    assign(:user, create(:user))
  end

  let(:layout) { false }

  context 'when partials of layouts/application is also rendered' do
    let(:layout) { 'layouts/application' }
    it 'displays title' do
      expect(rendered).to have_title full_title('Edit user')
    end
  end

  context 'when no layouts' do
    it 'renders form partial' do
      ['users/_form', 'shared/_error_messages'].each do |partial|
        expect(rendered).to render_template partial: partial
      end
    end

    it 'renders gravatar edit' do
      expect(rendered).to have_selector('div.gravatar_edit img')
      expect(rendered).to have_selector('div.gravatar_edit a', text: 'change')
    end
  end
end
