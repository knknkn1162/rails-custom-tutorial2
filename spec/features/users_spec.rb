require 'rails_helper'


def login_as(user)
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Log in'
end

RSpec.feature 'Users', type: :feature do
  let!(:user) { create(:user) }
  let!(:others) { create_list(:other, 31) }

  describe 'when login' do
    before(:each) { visit '/' }
    it 'success as valid user' do
      click_link 'Log in'
      expect(page).to have_content('Log in')
      login_as(user)

      expect(page).to have_selector("img[alt='#{user.name}']")
      expect(page).to have_content(user.name)
    end
  end

  describe 'when index page including pagination logged in as admin-user' do
    before(:each) {
      visit '/login'
      login_as(user)
      click_link 'Users'
    }

    let(:current_page) { 1 }
    let(:first_page_of_users) do
      User.paginate(page: current_page)
    end

    scenario 'renders index as admin including pagination' do
      expect(page).to have_selector 'div.pagination'
      expect(page).to have_selector "li.active a[href='/users?page=#{current_page}']"
      expect(page).to have_selector 'ul.users li', count: 30
    end

    scenario 'renders each users' do
      first_page_of_users.each do |user|
        expect(page).to have_selector(
          "a[href='/users/#{user.id}']", text: user.name
        )
      end
    end

    scenario 'delete the user via link' do
      first_page_of_users.each do |user|
        user_href = "/users/#{user.id}"
        user_tag = "a[href='#{user_href}']"
        if user.admin?
          expect(page).not_to have_selector(user_tag, text: 'delete')
        else
          expect(page).to have_selector(user_tag, text: 'delete')
          click_link 'delete', href: user_href
          # confirm destroy action
          expect(page).not_to have_selector(user_tag, text: 'delete')
        end
      end
    end
  end

  describe 'when index as non-admin' do
    before(:each) {
      visit '/login'
      login_as(others[0])
      click_link 'Users'
    }

    scenario 'doesnt render delete link' do
      expect(page).not_to have_link(text: 'delete')
    end
  end
end
