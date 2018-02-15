require 'rails_helper'

RSpec.describe 'users/index', type: :view do
  before(:each) do
    stubbed_current_user
    inject_users
    render template: 'users/index', layout: layout
  end

  let(:others) { create_list(:other, per_page + 1) }

  # current_user? and admin_current_user? depends on helper.current_user method
  # The method chain expression seems to be invalid!
  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(others[0])
  end

  # injection
  let(:inject_users) { assign(:users, users) }

  let(:layout) { false }
  let(:per_page) { 5 }

  context 'when pagination renders' do
    let(:users) { User.paginate(page: 1, per_page: per_page) }

    context 'when renders layout' do
      let(:layout) { 'layouts/application' }
      it 'displays title' do
        expect(rendered).to have_title full_title('All users')
      end
    end

    context 'when no layouts' do
      it 'displays pagination' do
        expect(rendered).to have_selector('div.pagination', count: 2)
      end

      it 'renders list of 5 users link' do
        expect(rendered).to have_selector('ul.users li', count: per_page)
      end
    end
  end
end
