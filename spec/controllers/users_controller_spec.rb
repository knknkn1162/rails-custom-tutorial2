require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:other) { create(:other) }

  let(:logged_in_user_ok) do
    # NOTE: The expression `controller.stub(:current_user).and_return(user)` occurs `Deprecation Warnings:`.
    allow(controller).to receive(:logged_in_user).and_return(true)
  end

  let(:correct_user_ok) do
    allow(controller).to receive(:correct_user).and_return(true)
  end

  let(:admin_user_ok) do
    allow(controller).to receive(:admin_user).and_return(true)
  end

  let(:ignore_before_action) do
    logged_in_user_ok
    correct_user_ok
    admin_user_ok
  end

  describe 'when #index' do
    describe 'when pagination doesnt exist' do
      let!(:users) do
        create_list(:other, 5)
      end
      before(:each) do
        ignore_before_action
        get :index, params: {}, session: {}
      end

      it 'has a 200 status code' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @users' do
        expect(assigns(:users)).to eq users
      end

      it 'renders the :index template' do
        expect(response).to render_template(:index)
      end
    end

    describe 'when pagination exists' do
      let!(:users) do
        create_list(:other, 31)
      end

      before(:each) do
        ignore_before_action
        get :index, params: { page: 1 }, session: {}
      end

      it 'lists list of @users' do
        assigned_users = assigns(:users)
        expect(assigned_users.size).to eq 30
        expect(assigned_users).to eq users[0..29]
      end
    end
  end

  describe 'GET #new' do
    before(:each) do
      get :new
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'generate new user' do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #show' do
    before do
      ignore_before_action
      get :show, params: { id: user.id }, session: {}
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq user
    end
  end

  describe 'POST #create' do
    let(:user_attrs) { attributes_for(:user) }
    before(:each) do
      ignore_before_action
    end

    let(:post_create) do
      post :create, params: { user: user_attrs }, session: {}
    end

    describe 'redirects the :create template if success' do
      it 'saves new user' do
        expect do
          post_create
        end.to change(User, :count).by(1)
      end

      it 'should get redirect status and redirect to show page' do
        post_create
        user = User.last
        # see https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L493-L553
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'should flash correctly' do
        post_create
        expect(flash[:success]).to be
      end
    end

    describe 're-renders the :new template if failure' do
      let(:post_create) do
        post :create, params: { user: attributes_for(:user, name: ' ') }
      end

      it 'renders new page' do
        post_create
        expect(response).to have_http_status(:success)
        expect(response).to render_template('users/new')
      end

      it 'doesnt flash' do
        expect(flash).to be_empty
      end
    end
  end

  describe 'GET #edit' do
    before(:each) do
      ignore_before_action
      get :edit, params: { id: user.id }, session: {}
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq user
    end
  end

  describe 'PATCH #update' do
    let!(:user) { create(:user) }
    before(:each) do
      ignore_before_action
    end

    let(:post_create) do
      patch :update, params: { user: other_attrs, id: user.id }, session: {}
    end

    describe 'when security check' do
      it 'should not allow the admin attr to be edited' do
        # forced to change admin user with patch update
        patch :update,
          params: {
            user: {
              admin: true
            },
            id: other.id
          },
          session: {}
        expect(other.reload.admin?).to be_falsy
      end
    end

    describe 'when success' do
      let!(:other_attrs) { attributes_for(:other) }
      it 'saves updated users' do
        expect do
          post_create
        end.to change(User, :count).by(0)
      end

      it 'updates users if success' do
        post_create
        user.reload

        expect(user.name).to eq other_attrs[:name]
        expect(user.email).to eq other_attrs[:email]
      end

      it 'redirects to :show' do
        post_create
        user = User.last
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'flashes' do
        post_create
        expect(flash).not_to be_empty
      end

      describe 'when updated with empty password' do
        let(:other_attrs) do
          attributes_for(
            :other,
            password: '',
            password_confirmation: ''
          )
        end

        it 'redirects to :show' do
          post_create
          user = User.last
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to("/users/#{user.id}")
        end
      end
    end

    describe 'when failure' do
      let!(:other_attrs) { attributes_for(:other, name: ' ') }
      it 'saves updated users' do
        expect do
          post_create
        end.to change(User, :count).by(0)
      end

      it 'redirects to :show' do
        post_create
        expect(response).to have_http_status(:success)
        expect(response).to render_template('users/edit')
      end
    end
  end

  describe 'when #destroy' do
    before(:each) do
      ignore_before_action
    end

    let!(:user) { create(:user) }
    let(:delete_destroy) do
      delete :destroy, params: { id: user.id }, session: {}
    end

    it 'delete the user' do
      expect do
        delete_destroy
      end.to change(User, :count).by(-1)
    end

    it 'redirects the :show template' do
      delete_destroy
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/users')
    end

    it 'flashes' do
      delete_destroy
      expect(flash).not_to be_empty
    end
  end

  # REVIEW: Should the method under before_filter be tested a lot?
  describe 'check before_action method' do
    controller do
      def update
      end

      def edit
      end

      def index
      end

      def destroy
      end
    end

    let(:stubbed_logged_in?) do
      allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
    end

    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(current_user_flag)
    end

    describe 'when logged_in_user calls' do
      let!(:logged_in_flag) { false }
      before(:each) do
        stubbed_logged_in?
        correct_user_ok
        admin_user_ok
        action
      end

      describe 'when #destroy' do
        let(:action) do
          delete :destroy, params: { id: user.id }, session: {}
        end
        it 'flash before #update if login fails' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq user_url(user)
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end

      describe 'when #index' do
        let(:action) { get :index, params: {}, session: {} }
        it 'flash before #update if login fails' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq users_url
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end

      describe 'when #update' do
        let(:action) { patch :update, params: { id: 0 }, session: {} }

        it 'flash before #update if login fails' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq user_url(build(:user, id: 0))
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end

      describe 'when #edit' do
        let(:action) { get :edit, params: { id: 0 }, session: {} }
        it 'flash before #update if success login' do
          expect(flash[:danger]).to be
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end
    end

    describe 'when correct_user calls' do
      # assume that current_user is differnt from user with params[:id]
      let!(:current_user_flag) { other }
      before(:each) do
        stubbed_current_user
        logged_in_user_ok
        admin_user_ok
        action
      end

      describe 'when #edit' do
        let(:action) { get :edit, params: { id: user.id }, session: {} }
        it 'redirects root path if current_user is other' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      describe 'when #update' do
        let(:action) { patch :update, params: { id: user.id }, session: {} }
        it 'redirects root path if current_user is other' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end
    end

    describe 'when admin_user calls' do
      let!(:current_user_flag) { other }
      before(:each) do
        stubbed_current_user
        logged_in_user_ok
        correct_user_ok
        action
      end

      describe 'when #destroy' do
        let(:action) { delete :destroy, params: { id: 0 }, session: {} }
        it 'redirects root path if current_user is other' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end
    end
  end
end
