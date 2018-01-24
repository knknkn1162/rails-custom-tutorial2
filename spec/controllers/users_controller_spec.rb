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
end
