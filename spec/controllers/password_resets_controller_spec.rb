require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  include UsersHelper
  before(:each) { stubbed_before_actions }

  let(:user) { create(:user, reset_digest: generate_digest(sample_token)) }
  let(:stubbed_before_actions) do
    stubbed_get_user_with_validation
    stubbed_check_expiration
  end

  # before filter stubs
  let(:stubbed_get_user_with_validation) do
    allow(controller).to receive(:get_user_with_validation).and_return(get_user_with_validation_flag)
  end

  let(:stubbed_check_expiration) do
    allow(controller).to receive(:check_expiration).and_return(check_expiration_flag)
  end

  # default
  let(:sample_token) { 'sample_token' }
  let(:check_expiration_flag) { true }
  let(:get_user_with_validation_flag) { true }

  describe 'GET #new' do
    let(:action) { get :new }
    before(:each) { action }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:action) do
      post :create, params: { password_reset: {
        email: user_email
      } }
    end

    # default
    let(:user_email) { user.email }

    context 'when success' do
      it 'assigns user' do
        action
        expect(assigns(:user).id).to eq user.id
      end
      it 'flashes info' do
        action
        expect(flash[:info]).to be
      end

      it 'returns http redirect and redirects to :new' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to render_template('/')
      end

      it 'store attrs' do
        action
        expect(assigns(:user).reset_token).to be

        user.reload
        expect(user.reset_digest).to be
        expect(user.reset_sent_at).to be
      end

      it 'sends mailer' do
        expect { action }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
    end

    context 'when failure' do
      before(:each) { action }

      let(:user_email) { 'dummy' }
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
    let(:action) do
      get :edit, params: { id: 'sample_token', email: user.email }
    end

    it 'returns http success' do
      action
      expect(response).to have_http_status(:success)
    end

    it 'assigns user id & token' do
      action
      assigned_user = assigns(:user)
      expect(assigned_user.id).to eq user.id
      expect(
        BCrypt::Password.new(user.reset_digest)
      ).to eq assigned_user.reset_token
    end

    context 'when before_action methods calls' do
      it 'calls get_user_with_validation' do
        expect(controller).to receive(:get_user_with_validation)
        action
      end

      it 'calls check_expiration' do
        expect(controller).to receive(:check_expiration)
        action
      end
    end
  end

  describe 'PATCH #update' do
    let(:action) do
      patch :update, params: { email: user.email, user: user_params, id: token }
    end

    # default
    let(:token) { 'sample_token' }
    let(:user_params) do
      { password: 'new_password',
      password_confirmation: 'new_password' }
    end

    context 'when password is empty' do
      before(:each) { action }
      let(:user_params) { { password: '' } }
      it 'raise blank error' do
        expect(assigns(:user).errors).not_to be_empty
      end

      it 'renders :edit' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('password_resets/edit')
      end
    end

    context 'when invalid params' do
      before(:each) { action }
      let(:user_params) { {
        password: 'wrong',
        password_confirmation: 'correct'
      } }

      it 'renders :edit' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template('password_resets/edit')
      end
    end

    context 'when valid params with changing admin' do
      before(:each) { action }
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
        expect(assigns(:user).admin).to be_truthy
      end

      it 'delete reset_digest' do
        expect(assigns(:user).reset_digest).to be_falsy
      end
    end

    context 'when valid user_params' do
      before(:each) { action }
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

    context 'when before_action methods calls' do
      it 'calls get_user_with_validation' do
        expect(controller).to receive(:get_user_with_validation)
        action
      end

      it 'calls check_expiration' do
        expect(controller).to receive(:check_expiration)
        action
      end
    end
  end

  describe 'check before_filter method' do
    controller do
      def update; end
    end

    context 'when get_user_with_validation calls' do
      let(:action) do
        patch :update, params: { id: 'dummy_token', email: email }, session: {}
      end
      let(:stubbed_get_user_with_validation) { false }
      let(:user) do
        allow_any_instance_of(User).to receive(:activated?).and_return(activated_flag)
        allow_any_instance_of(User).to receive(:authenticated?).and_return(authenticated_flag)
        create(:user)
      end

      # default
      let(:activated_flag) { true }
      let(:authenticated_flag) { true }

      # default
      let(:sample_token) { 'dummy_token' }
      let(:email) { user.email }
      let(:activated_flag) { true }
      let(:authenticated_flag) { true }

      context 'when invalid email' do
        before(:each) { action }
        let(:email) { 'dummy@gmail.com' }
        it 'doesnt assign user' do
          expect(assigns(:user)).not_to be
        end

        it 'redirects to root_url' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      context 'when un-activated user' do
        before(:each) { action }
        let(:activated_flag) { false }
        it 'assigns user' do
          expect(assigns(:user)).to eq user
        end

        it 'redirects_to_root_url' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      context 'when unauthorized user' do
        before(:each) { action }
        let(:authenticated_flag) { false }
        it 'assigns user' do
          expect(assigns(:user)).to eq user
        end

        it 'redirects_to_root_url' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      context 'when activated & authorized user(well-formed)' do
        it 'assigns user' do
          action
          expect(assigns(:user)).to eq user
        end

        it 'reaches update controller' do
          expect(controller).to receive(:update)
          action
        end
      end
    end

    context 'when check_expiration calls' do
      let(:action) do
        patch :update, params: { id: 'dummy_token', email: user.email }
      end
      let(:stubbed_check_expiration) { false }
      let(:user) do
        allow_any_instance_of(User).to receive(:password_reset_expired?).and_return(password_reset_expired_flag)
        create(:user)
      end

      # default
      let(:password_reset_expired_flag) { false }

      context 'when expired (failure)' do
        before(:each) { action }
        let(:password_reset_expired_flag) { true }
        it 'flashes danger' do
          expect(flash[:danger]).to be
        end

        it 'redirects new_password_reset_url' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to '/password_resets/new'
        end
      end

      context 'when not expired (succeed)' do
        it 'reaches update controller' do
          expect(controller).to receive(:update)
          action
        end
      end
    end
  end
end
