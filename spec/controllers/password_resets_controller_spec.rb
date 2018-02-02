require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  include UsersHelper
  let(:get_user_with_validation_ok) do
    allow(controller).to receive(:get_user_with_validation).and_return(true)
  end
  let(:user) { create(:user, reset_digest: generate_digest(sample_token)) }
  let(:ignore_before_filter) do
    get_user_with_validation_ok
  end

  #default
  let(:sample_token) { 'sample_token' }

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

  describe 'check before_filter method' do
    controller do
      def update
      end

      def edit
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
