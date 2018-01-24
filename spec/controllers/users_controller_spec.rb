require 'rails_helper'

RSpec.describe UsersController, type: :controller do

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
    it 'saves new user' do
      expect {
        post :create, params: { user: user_attrs }, session: {}
      }.to change(User, :count).by(1)
    end

    it 'redirects the :create template if success' do
      post :create, params: { user: user_attrs }, session: {}
      user = User.last
      # see https://github.com/rack/rack/blob/master/lib/rack/utils.rb#L493-L553
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:success]).to be
    end

    it 're-renders the :new template if failure' do
      post :create, params: { user: attributes_for(:user, name: ' ') }
      expect(response).to render_template('users/new')
      expect(flash).to be_empty
    end
  end

  describe 'check private method' do
  end
end
