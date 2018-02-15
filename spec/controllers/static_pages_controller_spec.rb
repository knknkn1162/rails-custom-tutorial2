require 'rails_helper'

RSpec.describe StaticPagesController, type: :controller do
  describe 'GET #home' do
    let(:stubbed_logged_in) do
      allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
      allow(controller).to receive(:current_user).and_return(user)
    end

    let(:user) do
      create(:user_with_microposts, microposts_count: 31)
    end
    let(:action) { get :home }

    before(:each) do
      stubbed_logged_in
      action
    end

    # default
    let(:logged_in_flag) { true }

    context 'when not logged_in' do
      let(:logged_in_flag) { false }
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      it 'doesnt assign micropost' do
        expect(assigns(:micropost)).not_to be
      end
    end

    context 'when logged_in' do
      it 'assigns micropost' do
        expect(assigns(:micropost)).to be
      end

      it 'assigns feed_items' do
        expect(assigns(:feed_items)).to eq user.microposts[0..29]
      end
    end
  end

  describe 'GET #help' do
    let(:action) { get :help }
    before(:each) { action }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #about' do
    let(:action) { get :about }
    before(:each) { action }

    it 'returns about success' do
      expect(response).to have_http_status(:success)
    end
  end
end
