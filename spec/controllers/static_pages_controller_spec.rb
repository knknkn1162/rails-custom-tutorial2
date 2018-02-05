require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe 'GET #home' do
    let(:stubbed_current_user) do
      allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
      allow(controller).to receive(:current_user).and_return(user)
    end

    let(:user) { create(:user) }

    before(:each) do
      stubbed_current_user
      get :home
    end

    describe 'when not logged_in' do
      let(:logged_in_flag) { false }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'doesnt assign micropost' do
        expect(assigns(:micropost)).not_to be
      end
    end

    describe 'when logged_in' do
      let(:logged_in_flag) { true }
      it 'assigns micropost' do
        expect(assigns(:micropost)).to be
      end
    end
  end

  describe 'GET #help' do
    it 'returns http success' do
      get :help
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #about' do
    it 'returns about success' do
      get :about
      expect(response).to have_http_status(:success)
    end
  end
end
