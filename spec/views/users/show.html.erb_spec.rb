require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    inject_instance
    render template: 'users/show', layout: layout
  end

  let(:user) do
    create(:user_with_microposts, microposts_count: microposts_count)
  end

  let(:microposts) do
    user.microposts.paginate(page: 1, per_page: per_page)
  end

  # injection
  let(:inject_instance) do
    inject_user
    inject_micropost
  end

  let(:inject_user) do
    assign(:user, user)
  end

  let(:inject_micropost) do
    assign(:microposts, microposts)
  end

  # defaults
  let(:layout) { false }
  let(:microposts_count) { per_page + 1 }
  let(:per_page) { 5 }

  context 'renders with layout' do
    let(:layout) { 'layouts/application' }
    it 'displays title' do
      expect(rendered).to have_title full_title(user.name)
    end
  end

  context 'renders no layouts' do
    let(:inject) { inject_user }
    it 'displays img and user_name' do
      expect(rendered).to have_selector("img[alt='#{user.name}']", class: 'gravatar')
      expect(rendered).to have_content(user.name)
    end

    context 'when no microposts' do
      let(:microposts_count) { 0 }
      it 'doesnt render micropost' do
        expect(rendered).not_to render_template partial: 'microposts/_micropost'
      end
    end

    context 'when renders with some microposts' do
      it 'renders form partial' do
        expect(rendered).to render_template partial: 'microposts/_micropost'
      end

      it 'displays microposts count' do
        expect(rendered).to match(/Microposts *.#{user.microposts.count}/)
      end

      it 'matches the number of list' do
        expect(rendered).to have_selector('ol.microposts li', count: 5)
      end

      it 'displays pagination' do
        expect(rendered).to have_selector('div.pagination')
      end
    end
  end
end
