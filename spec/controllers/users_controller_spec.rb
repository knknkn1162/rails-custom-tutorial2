require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    stubbed_before_actions
  end

  let(:stubbed_logged_in_user) do
    # NOTE: The expression `controller.stub(:current_user).and_return(user)` occurs `Deprecation Warnings:`.
    allow(controller).to receive(:logged_in_user).and_return(logged_in_user_flag)
  end

  let(:stubbed_correct_user) do
    allow(controller).to receive(:correct_user).and_return(correct_user_flag)
  end

  let(:stubbed_admin_user) do
    allow(controller).to receive(:admin_user).and_return(admin_user_flag)
  end

  let(:stubbed_before_actions) do
    stubbed_logged_in_user
    stubbed_correct_user
    stubbed_admin_user
  end

  # default
  let(:logged_in_user_flag) { true }
  let(:correct_user_flag) { true }
  let(:admin_user_flag) { true }

  describe 'GET #index' do
    before { users }
    let(:users) do
      create_list(:other, users_count, activated: activated_flag)
    end

    let(:action) do
      get :index, params: params, session: {}
    end

    # default
    let(:users_count) { 5 }
    let(:activated_flag) { true }
    let(:params) { {} }

    context 'when pagination doesnt exist' do
      before(:each) { action }
      it 'assigns @users' do
        expect(assigns(:users)).to eq users
      end

      it 'renders the :index template' do
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end

      context 'when all users un-activated' do
        let(:activated_flag) { false }
        before(:each) { action }
        it 'assigns @users' do
          expect(assigns(:users)).to be_empty
        end
      end
    end

    context 'when pagination exists' do
      let(:params) { { page: 1 } }
      let(:user_count) { 31 }
      before(:each) { action }
      it 'lists list of @users' do
        expect(assigns(:users)).to eq users[0..29]
      end
    end

    context 'when logged_in_user calls' do
      it 'calls' do
        expect(controller).to receive(:logged_in_user)
        action
      end
    end
  end

  describe 'GET #new' do
    let(:action) { get :new }
    before { action }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'generate new user' do
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #show' do
    before { action }

    let(:user) { create(:user_with_microposts, microposts_count: 31, activated: activated_flag) }
    let(:action) do
      get :show, params: { id: user.id, page: 1 }, session: {}
    end

    # default
    let(:activated_flag) { true }

    context 'when un-activated user' do
      let(:activated_flag) { false }
      it 'returns http success' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end
    end

    context 'when activated user' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'assigns @user' do
        expect(assigns(:user)).to eq user
      end

      it 'assigns @microposts' do
        expect(assigns(:microposts)).to match_array user.microposts[0..29]
      end
    end
  end

  describe 'POST #create' do
    let(:action) do
      post :create, params: { user: user_attrs }, session: {}
    end

    # default
    let(:user_attrs) { attributes_for(:user) }

    context 'when success' do
      it 'saves new user' do
        expect { action }.to change(User, :count).by(1)
      end

      it 'should get redirect status and redirect to show page' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end

      it 'should flash correctly' do
        action
        expect(flash).not_to be_empty
      end
    end

    context 'when failure' do
      let(:user_attrs) { attributes_for(:user, name: ' ') }
      before { action }
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
    let(:action) do
      get :edit, params: { id: user.id }, session: {}
    end

    it 'returns http success' do
      action
      expect(response).to have_http_status(:success)
    end

    it 'assigns @user' do
      action
      expect(assigns(:user)).to eq user
    end

    context 'when before_action method calls' do
      it 'calls logged_in_user' do
        expect(controller).to receive(:logged_in_user)
        action
      end

      it 'calls correct_user' do
        expect(controller).to receive(:correct_user)
        action
      end
    end
  end

  describe 'PATCH #update' do
    let!(:user) { create(:user) }
    let(:other_attrs) { attributes_for(:other) }
    let(:action) do
      patch :update, params: { user: new_user_attrs, id: user_id }, session: {}
    end

    # default
    let(:user_id) { user.id }
    let(:new_user_attrs) { attributes_for(:other) }

    context 'when checks security' do
      # forced to change admin user with patch update
      let(:new_user_attrs) { { admin: false } }
      it 'should not allow the admin attr to be edited' do
        action
        expect(user.reload.admin?).to be_truthy
      end
    end

    context 'when success' do
      it 'saves updated users' do
        expect { action }.to change(User, :count).by(0)
      end

      it 'updates users if success' do
        action
        user.reload
        expect(user.name).to eq new_user_attrs[:name]
        expect(user.email).to eq new_user_attrs[:email]
      end

      it 'redirects to :show' do
        action
        user = User.last
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'flashes' do
        action
        expect(flash).not_to be_empty
      end

      context 'when updated with empty password' do
        let(:new_user_attrs) do
          attributes_for(:other, password: '', password_confirmation: '')
        end
        it 'redirects to :show' do
          action
          user = User.last
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to("/users/#{user.id}")
        end

        it 'doesnt change password' do
          old_user_password = user.password
          action
          user.reload
          expect(user.password).to be
          expect(user.password).to eq old_user_password
        end
      end
    end

    context 'when failure' do
      let(:new_user_attrs) { attributes_for(:other, name: ' ') }
      it 'saves updated users' do
        expect { action }.to change(User, :count).by(0)
      end

      it 'redirects to :show' do
        action
        expect(response).to have_http_status(:success)
        expect(response).to render_template('users/edit')
      end
    end

    context 'when before_action method calls' do
      it 'calls logged_in_user' do
        expect(controller).to receive(:logged_in_user)
        action
      end

      it 'calls correct_user' do
        expect(controller).to receive(:correct_user)
        action
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:user) { create(:user) }
    let(:action) do
      delete :destroy, params: { id: user.id }, session: {}
    end

    it 'delete the user' do
      expect { action }.to change(User, :count).by(-1)
    end

    it 'redirects the :show template' do
      action
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/users')
    end

    it 'flashes' do
      action
      expect(flash).not_to be_empty
    end

    context 'when before_action method calls' do
      it 'calls logged_in_user & admin_user' do
        expect(controller).to receive(:logged_in_user)
        expect(controller).to receive(:admin_user)
        action
      end
    end
  end

  context 'when check before_action method' do
    controller do
      def update; end

      def destroy; end
    end

    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(current_user_flag)
    end
    let(:user) { create(:user) }
    let(:other) { create(:other) }

    context 'when logged_in_user calls' do
      let(:stubbed_logged_in?) do
        allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
      end
      let(:stubbed_logged_in_user) { false }
      let(:action) { patch :update, params: { id: id }, session: {} }
      before(:each) do
        stubbed_logged_in?
      end

      # default
      let(:logged_in_flag) { false }
      let(:id) { 0 }

      context 'when logged_in' do
        let(:logged_in_flag) { true }

        it 'calls #update' do
          expect(controller).to receive(:update)
          action
        end
      end

      context 'when not logged_in' do
        before(:each) { action }
        it 'flashes' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq user_url(build(:user, id: id))
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end
    end

    context 'when correct_user calls' do
      let(:action) { patch :update, params: { id: user.id }, session: {} }
      let(:stubbed_correct_user) { false }
      before(:each) do
        stubbed_current_user
      end

      # default
      let(:current_user_flag) { user }

      context 'when current_user is other' do
        let(:current_user_flag) { other }
        before { action }
        it 'redirects root path if current_user is other' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      context 'when current_user is user' do
        it 'calls #update' do
          expect(controller).to receive(:update)
          action
        end
      end
    end

    context 'when admin_user calls' do
      before(:each) do
        stubbed_current_user
      end
      let(:action) { delete :destroy, params: { id: 0 }, session: {} }

      # default
      let(:current_user_flag) { user }
      let(:stubbed_admin_user) { false }

      context 'when current_user is non-admin-user' do
        let(:current_user_flag) { other }
        before { action }
        it 'redirects root path if current_user is other' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/')
        end
      end

      context 'when current_user is admin user' do
        it 'calls #destroy' do
          expect(controller).to receive(:destroy)
          action
        end
      end
    end
  end
end
