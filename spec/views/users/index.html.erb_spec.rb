require 'rails_helper'

RSpec.describe 'users/index', type: :view do

  let!(:others) { create_list(:other, 31) }

  describe 'when pagination doesnt render' do
    before do
      # NOTE: default users per-page is 30
      assign(:users, User.paginate(page: 1, per_page: 50))
    end

    it 'displays title' do
      render template: 'users/index', layout: 'layouts/application'
      expect(rendered).to have_title full_title('All users')
    end

    it 'renders form partial' do
      render
      expect(rendered).to render_template partial: 'users/_user'
    end

    it 'displays pagination' do
      render
      expect(rendered).not_to have_selector('div.pagination')
    end

    describe 'users/_user', type: :view do
      it 'renders list of 20, users' do
        render
        expect(rendered).to have_selector('ul.users li', count: 31)
        expect(rendered).to have_selector('ul.users a', count: 31)
      end
    end
  end

  describe 'when pagination renders' do
    before do
      # NOTE: default users per-page is 30
      assign(:users, User.paginate(page: 1, per_page: 20))
    end

    it 'displays pagination' do
      render
      expect(rendered).to have_selector('div.pagination', count: 2)
    end

    describe 'users/_user', type: :view do
      it 'renders list of 20, users' do
        render
        expect(rendered).to have_selector('ul.users li', count: 20)
        expect(rendered).to have_selector('ul.users a', count: 20)
      end
    end
  end
end
