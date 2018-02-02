require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  include UsersHelper
  let(:stubbed_get_user_with_validation) do
    allow(controller).to receive(:get_user_with_validation).and_return(get_user_with_validation_flag)
  end

  let(:stubbed_check_expiration) do
    allow(controller).to receive(:check_expiration).and_return(check_expiration_flag)
  end

  let(:user) { create(:user, reset_digest: generate_digest(sample_token)) }
  let(:ignore_before_filter) do
    stubbed_get_user_with_validation
    stubbed_check_expiration
  end

  #default
  let(:sample_token) { 'sample_token' }
  let(:check_expiration_flag) { true }
  let(:get_user_with_validation_flag) { true }

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
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
        end.to change { ActionMailer::Base.deliveries.size }.by(1)
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

  describe 'GET #edit' do
    before(:each) do
      ignore_before_filter
      get :edit, params: { id: 'sample_token', email: user.email }
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns user id & token' do
      assigned_user = assigns(:user)
      expect(assigned_user.id).to eq user.id
      expect(
        BCrypt::Password.new(user.reset_digest)
      ).to eq assigned_user.reset_token
    end
  end

  describe 'PATCH #update' do
    let(:token) { 'sample_token' }
    before(:each) do
      ignore_before_filter
      patch :update, params: { email: user.email, user: user_params, id: token }
    end

    # default
    let(:user_params) do
      { password: 'new_password',
      password_confirmation: 'new_password' }
    end

    describe 'when password is empty' do
      let(:user_params) { { password: '' } }
      it 'raise blank error' do
        assigned_user = assigns(:user)
        expect(assigned_user.errors).not_to be_empty
      end

      it 'renders :edit' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('password_resets/edit')
      end
    end

    describe 'when invalid params' do
      let(:user_params) { {
        password: 'wrong',
        password_confirmation: 'correct'
      } }

      it 'renders :edit' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('password_resets/edit')
      end
    end

    describe 'when valid params with changing admin' do
      let(:user_params) { {
        password: 'new_password',
        password_confirmation: 'new_password',
        admin: false
      } }

      it 'renders :show' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'doesnt change admin flag' do
        assigned_user = assigns(:user)
        expect(assigned_user.admin).to be_truthy
      end
    end

    describe 'when valid user_params' do
      it 'redirects :show' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'flashes success' do
        expect(flash[:success]).to be
      end

      it 'stores session' do
        expect(session).not_to be_empty
      end
    end
  end

  describe 'check before_filter method' do
    controller do
      def update
      end

      def edit
      end
    end

    describe 'when check_expiration calls' do
      let(:stubbed_password_reset_expired?) do
        allow_any_instance_of(User).to receive(:password_reset_expired?).and_return(password_reset_expired_flag)
      end

      # default
      let(:password_reset_expired_flag) { false }
      before(:each) do
        stubbed_get_user_with_validation
        stubbed_password_reset_expired?
        action
      end

      describe 'when GET #edit' do
        let(:action) do
          get :edit, params: { id: 'dummy', email: user.email }
        end

        describe 'when expired (failure)' do
          let(:password_reset_expired_flag) { true }
          it 'flashes danger' do
            expect(flash[:danger]).to be
          end

          it 'redirects new_password_reset_url' do
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to '/password_resets/new'
          end
        end

        describe 'when not expired (succeed)' do
          it 'has success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'when PATCH #update' do
        let(:action) do
          patch :update, params: { id: 'dummy', email: user.email }
        end

        describe 'when expired (failure)' do
          let(:password_reset_expired_flag) { true }
          it 'flashes danger' do
            expect(flash[:danger]).to be
          end

          it 'redirects new_password_reset_url' do
            expect(response).to have_http_status(:redirect)
            expect(response).to redirect_to '/password_resets/new'
          end
        end

        describe 'when not expired (succeed)' do
          it 'has success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end
    end

    describe 'when get_user_with_validation calls' do
      let(:stubbed_activated) do
        allow_any_instance_of(User).to receive(:activated?).and_return(activated_flag)
      end
      let(:stubbed_authenticated) do
        allow_any_instance_of(User).to receive(:authenticated?).and_return(authenticated_flag)
      end

      # action
      before(:each) do
        stubbed_activated
        stubbed_authenticated
        action
      end

      # default
      let(:email_flag) { user.email }
      let(:assigned_user) { assigns(:user) }
      let(:activated_flag) { true }
      let(:authenticated_flag) { true }

      # expectations
      let(:expect_assigned_user) do
        expect(assigned_user).to eq user
      end

      let(:expect_redirects_to_root) do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end

      describe 'when GET #edit' do
        let(:action) do
          get :edit, params: { id: sample_token, email: email_flag }, session: {}
        end

        describe 'when invalid email' do
          let(:email_flag) { 'dummy@gmail.com' }
          it 'doesnt assign user' do
            expect(assigned_user).not_to be
          end

          it 'redirects to root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when un-activated user' do
          let(:activated_flag) { false }
          it 'assigns user' do
            expect_assigned_user
          end

          it 'redirects_to_root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when unauthorized user' do
          let(:authenticated_flag) { false }
          it 'assigns user' do
            expect_assigned_user
          end

          it 'redirects_to root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when activated & authorized user' do
          it 'assigns user' do
            expect_assigned_user
          end

          it 'has success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end

      describe 'when PATCH #update' do
        let(:action) do
          patch :update, params: { id: sample_token, email: email_flag }, session: {}
        end

        describe 'when invalid email' do
          let(:email_flag) { 'dummy@gmail.com' }
          it 'doesnt assign user' do
            expect(assigned_user).not_to be
          end

          it 'redirects to root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when un-activated user' do
          let(:activated_flag) { false }
          it 'assigns user' do
            expect_assigned_user
          end

          it 'redirects_to_root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when unauthorized user' do
          let(:authenticated_flag) { false }
          it 'assigns user' do
            expect_assigned_user
          end

          it 'redirects_to root_url' do
            expect_redirects_to_root
          end
        end

        describe 'when activated & authorized user' do
          it 'assigns user' do
            expect_assigned_user
          end

          it 'has success status' do
            expect(response).to have_http_status(:success)
          end
        end
      end
    end
  end
end
