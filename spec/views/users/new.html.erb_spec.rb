require 'rails_helper'

RSpec.describe 'users/new.html.erb', type: :view do
  before(:each) do
    inject_user
    render template: 'users/new', layout: layout
  end

  let(:inject_user) { assign(:user, build(:user)) }
  let(:layout) { false }

  context 'when layout includes in layouts/application directory' do
    let(:layout) { 'layouts/application' }
    it 'has correct title' do
      expect(rendered).to have_title full_title('Sign up')
    end
  end

  context 'when no layouts' do
    it 'renders partial pages' do
      ['users/_form', 'shared/_error_messages'].each do |partial|
        expect(rendered).to render_template partial: partial
      end
    end
  end
end
