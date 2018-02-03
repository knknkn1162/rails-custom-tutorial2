require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'renders with layout' do
    before(:each) do
      user = build(:user)
      assign(:user, user)
    end

    it 'displays title' do
      render template: 'users/show', layout: 'layouts/application'
      expect(rendered).to have_title full_title(build(:user).name)
    end
  end

  context 'when renders users/show only' do
    context 'with no microposts' do
      let(:user) { create(:user) }
      before(:each) do
        assign(:user, user)
        render
      end

      it 'displays img and user_name' do
        expect(rendered).to have_selector("img[alt='#{user.name}']",
                                          class: 'gravatar')
        expect(rendered).to have_content(user.name)
      end

      it 'doesnt render micropost' do
        expect(rendered).not_to render_template partial: 'microposts/micropost'
      end
    end

    context 'renders with microposts' do
      let!(:user) { create(:user_with_microposts, microposts_count: 31) }
      let(:microposts) { user.microposts.paginate(page: 1, per_page: 30) }
      before(:each) do
        assign(:user, user)
        assign(:microposts, microposts)
        # ActionView::Template::Error:
        # No route matches {:action=>"show", :controller=>"users", :page=>1}
        # How to avoid this problem??
        # Ans. Use params option in will_paginate@view
        render template: 'users/show'
      end

      it 'renders form partial' do
        expect(rendered).to render_template partial: 'microposts/_micropost'
      end

      it 'displays microposts count' do
        expect(rendered).to match "Microposts *.#{user.microposts.count}"
      end

      it 'matches the number of list' do
        expect(rendered).to have_selector('ol.microposts li', count: 30)
      end

      it 'displays pagination' do
        expect(rendered).to have_selector('div.pagination')
      end
    end
  end
end
