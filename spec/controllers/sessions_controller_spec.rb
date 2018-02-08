require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    let(:action) { get :new }
    before(:each) { action }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:user) do
      create(:user, activated: activated_flag)
    end
    let(:action) do
      post :create, params: { session: {
        email: user_email,
        password: user_password,
        remember_me: remember_me_flag
      } }
    end

    # default
    let(:user_email) { user.email }
    let(:user_password) { user.password }
    # NOTE: checkedbox expresses '1', not true!
    let(:remember_me_flag) { '1' }
    let(:activated_flag) { true }

    context 'when success' do
      it 'saves new user' do
        expect { action }.to change(User, :count).by(1)
      end

      it 'redirects the :create template if success' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      context 'when forwarding_url is stored in session' do
        let(:store_forwarding_url) do
          session[:forwarding_url] = root_url
        end
        before(:each) do
          store_forwarding_url
          action
        end
        it 'redirects root_url' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      it 'doesnt flash' do
        action
        expect(flash).to be_empty
      end

      it 'stores logged_in' do
        action
        expect(session[:user_id]).to eq user.id
      end

      # REVIEW: Is it all right to test cookies??
      it 'checks non-empty cookies' do
        action
        assigned_user = assigns(:user)
        # see https://stackoverflow.com/a/5482517/8774173
        jar = request.cookie_jar
        jar.signed[:user_id] = user.id
        # Use response.cookies after the action to specify outcomes
        # see also https://relishapp.com/rspec/rspec-rails/docs/controller-specs/cookies
        expect(response.cookies['user_id']).to eq jar[:user_id]
        expect(
          response.cookies['remember_token']
        ).to eq assigned_user.remember_token
      end

      context 'when checkbox is true' do
        let(:remember_me_flag) { '1' }
        before(:each) { action }
        it 'contains remember_token, remember_digest attr and cookies' do
          expect(assigns(:user).remember_token).to be
          expect(assigns(:user).remember_digest).to be
          expect(response.cookies).not_to be_empty
        end
      end

      context 'when checkbox is false' do
        let(:remember_me_flag) { '0' }
        before(:each) { action }
        it 'doesnt contains remember_token, remember_digest attr and cookies' do
          assigned_user = assigns(:user)
          expect(assigns(:user).remember_token).not_to be
          expect(assigns(:user).remember_digest).not_to be
          expect(response.cookies).to be_empty
        end
      end

      it 'assigns last user' do
        action
        expect(assigns(:user)).to eq User.last
      end
    end

    context 'when failure' do
      before(:each) { action }

      context 'when fails the email' do
        let(:user_email) { 'dummy' }
        it 'renders the sessions/new template' do
          expect(response).to have_http_status(:success)
          expect(response).to render_template('sessions/new')
        end

        it 'flash danger' do
          expect(flash[:danger]).to be
        end
      end

      context 'when fails the password' do
        let(:user_password) { 'dummy' }
        it 'renders the sessions/new template' do
          expect(response).to have_http_status(:success)
          expect(response).to render_template('sessions/new')
        end

        it 'flash danger' do
          expect(flash[:danger]).to be
        end
      end

      context 'when unactivated user' do
        let(:activated_flag) { false }
        it 'renders the sessions/new template' do
          expect(flash[:warning]).to be
        end

        it 'flash danger' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to '/'
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(current_user_flag)
    end

    let(:action) do
      delete :destroy, params: { id: user_id }
    end

    # default
    let(:user_id) { user.id }
    let(:current_user_flag) { user }

    it 'doesnt change User.count' do
      expect { action }.to change(User, :count).by(0)
    end

    it 'returns http success' do
      action
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/')
    end

    context 'when current_user exists' do
      let(:user) { create(:user, remember_token: 'dummy_token') }
      let(:store_user_id) { session[:user_id] = user.id }
      let(:store_cookies) do
        request.cookies['user_id'] = 10
        request.cookies['remember_token'] = 'dummy'
      end

      before(:each) do
        store_user_id
        store_cookies
        action
      end

      it 'forgets remember digests' do
        expect(user.remember_digest).not_to be
      end

      it 'deletes session' do
        expect(session[:user_id]).not_to be
      end

      it 'deletes cookies' do
        expect(response.cookies['user_id']).not_to be
        expect(response.cookies['remember_token']).not_to be
      end
    end
  end
end
