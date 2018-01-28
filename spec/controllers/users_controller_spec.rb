require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:logged_in_user_ok) {
    controller.stub(:logged_in_user).and_return(true)
  }
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
    let(:user) { create(:user) }
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
    let(:user) { create(:user) }
    before(:each) do
      logged_in_user_ok
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

  describe 'check before_action method' do
    describe 'when logged_in_user calls' do
      controller do
        def update
        end

        def edit
        end
      end

      let(:user) { create(:user) }
      let(:login) { session[:user_id] = user.id }

      describe 'when #update' do
        let(:patch_update) { patch :update, params: { id: 0 }, session: {} }

        it 'flash before #update if success login' do
          controller.stub(:logged_in?).and_return(false)
          patch_update
          expect(flash[:danger]).to be
        end

        it 'redirects login path if success login' do
          controller.stub(:logged_in?).and_return(false)
          patch_update
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end

        it 'does nothing if login fails' do
          controller.stub(:logged_in?).and_return(true)
          patch_update
          expect(flash).to be_empty
          expect(response).to have_http_status(:success)
        end
      end

      describe 'when #edit' do
        let(:get_edit) { get :edit, params: { id: 0 }, session: {} }
        it 'flash before #update if success login' do
          controller.stub(:logged_in?).and_return(false)
          get_edit
          expect(flash[:danger]).to be
        end

        it 'redirects login path if success login' do
          controller.stub(:logged_in?).and_return(false)
          get_edit
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end

        it 'does nothing if login fails' do
          controller.stub(:logged_in?).and_return(true)
          get_edit
          expect(flash).to be_empty
          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
