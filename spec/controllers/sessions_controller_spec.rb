require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create if success' do
    let(:post_user) {
      create(:user) do |user|
        post :create, params: { session: {
          email: user.email,
          password: user.password
        } }
      end
    }
    it 'saves new user' do
      expect {
        post_user
      }.to change(User, :count).by(1)
    end

    it 'redirects the :create template if success' do
      user = post_user
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(user_path(user))
    end

    it 'doesnt flash' do
      post_user
      expect(flash).to be_empty
    end
  end

  describe 'POST #create if email failure' do
    let(:login_invalid_user) do
      create(:user) do |user|
        post :create, params: { session: {
          email: 'dummy@password.com',
          password: user.password
        } }
      end
    end

    it 'renders the sessions/new template' do
      login_invalid_user
      expect(response).to have_http_status(:success)
      expect(response).to render_template('sessions/new')
    end

    it 'flash danger' do
      login_invalid_user
      expect(flash[:danger]).to be
    end
  end

  describe 'POST #create if password failure' do
    let(:login_invalid_user) do
      create(:user) do |user|
        post :create, params: { session: {
          email: user.email,
          password: user.password + 'dummy'
        } }
      end
    end

    it 'renders the sessions/new template' do
      login_invalid_user
      expect(response).to have_http_status(:success)
      expect(response).to render_template('sessions/new')
    end

    it 'flash danger' do
      login_invalid_user
      expect(flash[:danger]).to be
    end
  end
end
