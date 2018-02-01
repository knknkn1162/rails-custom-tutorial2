require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

  describe 'GET #new' do
    it 'returns http success' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:post_create) do
      create(:user) do |user|
        post :create, params: { session: {
          email: user.email,
          password: user_password,
          remember_me: remember_me_flag,
          activated: activated_flag
        } }
      end
    end
    describe 'if success' do
      let(:user_password) { attributes_for(:user)[:password] }
      let(:activated_flag) { true }
      # NOTE: checkedbox expresses '1', not true!
      let(:remember_me_flag) { '1' }

      it 'saves new user' do
        expect do
          post_create
        end.to change(User, :count).by(1)
      end

      it 'redirects the :create template if success' do
        user = post_create
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'redirects the :other template if forwarding_url is stored in session' do
        session[:forwarding_url] = root_url
        post_create
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')

        expect(session[:forwarding_url]).not_to be
      end

      it 'doesnt flash' do
        post_create
        expect(flash).to be_empty
      end

      it 'contains user_id in session to confirm log_in method' do
        expect(session[:user_id]).not_to be
        user = post_create
        expect(session[:user_id]).to eq user.id
      end

      it 'should contain non-empty flash' do
        post_create
        expect(flash).to be_empty
      end

      it 'should work contain non-empty cookies' do
        user = post_create
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

      describe 'when checkbox is true' do
        let(:remember_me_flag) { '1' }
        it 'contains remember_token, remember_digest attr and cookies' do
          post_create
          assigned_user = assigns(:user)
          expect(assigned_user.remember_token).to be
          expect(assigned_user.remember_digest).to be
        end
      end

      describe 'when checkbox is false' do
        let(:remember_me_flag) { '0' }
        it 'doesnt contains remember_token, remember_digest attr and cookies' do
          post_create
          assigned_user = assigns(:user)
          expect(assigned_user.remember_token).not_to be
          expect(assigned_user.remember_digest).not_to be
          expect(response.cookies).to be_empty
        end
      end

      it 'assigns last user' do
        post_create
        expect(assigns(:user)).to eq User.last
      end
    end

    # describe 'when failure' do
      # describe 'if email failure' do
        # let(:login_invalid_user) do
          # create(:user) do |user|
            # post :create, params: { session: {
              # email: 'dummy@password.com',
              # password: user.password
            # } }
          # end
        # end

        # it 'renders the sessions/new template' do
          # login_invalid_user
          # expect(response).to have_http_status(:success)
          # expect(response).to render_template('sessions/new')
        # end

        # it 'flash danger' do
          # login_invalid_user
          # expect(flash[:danger]).to be
        # end
      # end

      # describe 'if password failure' do
        # let(:login_invalid_user) do
          # create(:user) do |user|
            # post :create, params: { session: {
              # email: user.email,
              # password: user.password + 'dummy'
            # } }
          # end
        # end

        # it 'renders the sessions/new template' do
          # login_invalid_user
          # expect(response).to have_http_status(:success)
          # expect(response).to render_template('sessions/new')
        # end

        # it 'flash danger' do
          # login_invalid_user
          # expect(flash[:danger]).to be
        # end
      # end
    # end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }

    let(:delete_user) do
      delete :destroy, params: { id: user.id }
    end

    it 'doesnt change User.count' do
      expect { delete_user }.to change(User, :count).by(0)
    end

    it 'returns http success' do
      delete_user
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/')
    end

    it 'forgets remember_digests' do
      other = create(:other, remember_token: 'dummy')
      session[:user_id] = other.id
      delete :destroy, params: { id: other.id }
      expect(other.remember_digest).not_to be
    end

    it 'deletes session' do
      session[:user_id] = user.id
      delete_user
      expect(session[:user_id]).not_to be
    end

    it 'deletes cookies' do
      request.cookies['user_id'] = 10
      request.cookies['remember_token'] = 'dummy'
      delete_user
      expect(response.cookies['user_id']).not_to be
      expect(response.cookies['remember_token']).not_to be
    end
  end
end
