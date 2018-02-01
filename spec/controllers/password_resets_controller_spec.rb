require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:post_create) do
      post :create, params: { password_reset: {
        email: user_email
      } }
    end

    # default
    let(:user_email) { user.email }

    describe 'if success' do
      it 'assigns user' do
        post_create
        expect(assigns(:user).id).to eq user.id
      end
      it 'flashes info' do
        post_create
        expect(flash[:info]).to be
      end

      it 'returns http redirect and redirects to :new' do
        post_create
        expect(response).to have_http_status(:redirect)
        expect(response).to render_template('/')
      end

      it 'store attrs' do
        post_create
        assigned_user = assigns(:user)
        expect(assigned_user.reset_token).to be

        user.reload
        expect(user.reset_digest).to be
        expect(user.reset_sent_at).to be
      end

      it 'sends mailer' do
        expect do
          post_create
        end.to change{ ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    describe 'if failure' do
      before(:each) do
        post_create
      end

      let!(:user_email) { 'dummy' }
      it 'flashes danger' do
        expect(flash[:danger]).to be
      end

      it 'returns http success and renders :new' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('password_resets/new')
      end
    end
  end

  # describe 'GET #edit' do
    # it 'returns http success' do
      # get :edit
      # expect(response).to have_http_status(:success)
    # end
  # end
end
