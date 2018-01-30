require 'rails_helper'


def login_as_user
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
      login_as_user

      expect(page).to have_selector("img[alt='#{user.name}']")
      expect(page).to have_content(user.name)
    end
  end
end
