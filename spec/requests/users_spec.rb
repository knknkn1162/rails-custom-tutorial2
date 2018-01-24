require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    before(:each) do
      get signup_path
    end

    it 'has 200 status_code' do
      expect(response).to have_http_status(:success)
    end

    it 'renders users/new template' do
      expect(response).to render_template('users/new')
    end

    it 'assigns empty users' do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'POST /users if success' do
    before(:each) do
      get signup_path
      post users_path, params: { user: attributes_for(:user) }
    end

    it 'has redirect status' do
      expect(response).to have_http_status(:redirect)
    end

    it 'renders user/show template' do
      follow_redirect!
      expect(response).to render_template('users/show')
    end

    it 'assigns user which has name and email' do
      user = build(:user)
      posted_user = assigns(:user)
      expect(
        [posted_user['name'], posted_user['email']]
      ).to eq [user['name'], user['email']]
    end
  end

  describe 'POST /users if failure' do
    before(:each) do
      get signup_path
      post users_path, params: { user: attributes_for(:user, name: ' ') }
    end

    it 'has success status' do
      expect(response).to have_http_status(:success)
    end

    it 'renders user/new template' do
      expect(response).to render_template('users/new')
    end

    it 'assigns user with errors' do
      user = assigns(:user)
      expect(user.errors.any?).to be_truthy
    end
  end
end
