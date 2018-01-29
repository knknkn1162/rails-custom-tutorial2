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

  describe 'when #index' do
    let!(:users) do
      create_list(:other, 5)
    end
    before(:each) do
      logged_in_user_ok
      get :index, params: {}, session: {}
    end

    it 'has a 200 status code' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @users' do
      expect(assigns(:users)).to match_array users
    end

    it 'renders the :index template' do
      expect(response).to render_template(:index)
    end
  end

  describe 'GET #new' do
    before(:each) { get :new }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'generate new user' do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #show' do
    before {
      get :show, params: { id: user.id }, session: {}
    }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      expect(assigns(:user)).to eq user
    end
  end

  describe 'POST #create' do
    let(:user_attrs) { attributes_for(:user) }
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
      before(:each) do
        post :create, params: { user: attributes_for(:user, name: ' ') }
      end

      it 'renders new page' do
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
      logged_in_user_ok
      correct_user_ok
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
    let(:post_create) do
      logged_in_user_ok
      correct_user_ok
      patch :update, params: { user: other_attrs, id: user.id }, session: {}
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

  # REVIEW: Should the method under before_filter be tested a lot?
  describe 'check before_action method' do
    controller do
      def update
      end

      def edit
      end

      def index
      end
    end

    let(:logged_in_true) do
      allow(controller).to receive(:logged_in?).and_return(true)
    end

    let(:logged_in_false) do
      allow(controller).to receive(:logged_in?).and_return(false)
    end


    let(:current_my_user) {
      allow(controller).to receive(:current_user).and_return(user)
    }

    let(:current_other_user) {
      allow(controller).to receive(:current_user).and_return(other)
    }

    describe 'when logged_in_user calls' do
      before(:each) {
        correct_user_ok
      }

      describe 'when #update' do
        let(:patch_update) { patch :update, params: { id: 0 }, session: {} }

        it 'flash before #update if login fails' do
          logged_in_false
          patch_update
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          allow(controller).to receive(:logged_in?).and_return(false)
          patch_update
          expect(session[:forwarding_url]).to eq user_url(build(:user, id: 0))
        end

        it 'redirects login path if login fails' do
          logged_in_false
          patch_update
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end

        it 'does nothing if login success' do
          logged_in_true
          patch_update
          expect(flash).to be_empty
          expect(response).to have_http_status(:success)
        end
      end

      describe 'when #edit' do
        let(:get_edit) { get :edit, params: { id: 0 }, session: {} }
        it 'flash before #update if success login' do
          logged_in_false
          get_edit
          expect(flash[:danger]).to be
        end

        it 'redirects login path if login fails' do
          logged_in_false
          get_edit
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end

        it 'does nothing if login success' do
          logged_in_true
          get_edit
          expect(flash).to be_empty
          expect(response).to have_http_status(:success)
        end
      end
    end

    describe 'when correct_user called' do
      describe 'when #edit' do
        let(:get_edit) { get :edit, params: { id: user.id }, session: {} }

        it 'redirects root path if current_user is other' do
          current_other_user
          get_edit

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end


        it 'successes if current_user is user' do
          current_my_user
          get_edit

          expect(response).to have_http_status(:success)
        end
      end

      describe 'when #update' do
        let(:patch_update) do
          patch :update, params: { id: user.id }, session: {}
        end

        it 'redirects root path if current_user is other' do
          current_other_user
          patch_update
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end

        it 'does nothing if login success' do
          current_my_user
          patch_update
          expect(flash).to be_empty
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
