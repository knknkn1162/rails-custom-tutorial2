require 'rails_helper'

RSpec.describe MicropostsController, type: :controller do
  let(:logged_in_user_ok) do
    allow(controller).to receive(:logged_in_user).and_return(true)
  end

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:micropost) { build(:micropost) }
    let(:action) do
      post :create, params: {
        micropost: { content: content }
      }, session: {}
    end
    let(:content) { micropost.content }

    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(user)
    end

    before(:each) do
      logged_in_user_ok
      stubbed_current_user
    end

    describe 'when it saves successfully' do
      it 'saves the micropost' do
        expect { action }.to change(Micropost, :count).by(1)
      end

      it 'flashes success sign' do
        action
        expect(flash[:success]).to be
      end

      it 'renders root' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end
    end

    describe 'when failure' do
      let(:content) { ' ' }
      it 'doesnt save the micropost' do
        expect { action }.to change(Micropost, :count).by(0)
      end

      it 'renders home page' do
        action
        expect(response).to have_http_status(:success)
        expect(response).to render_template('static_pages/home')
      end

      it 'renders empty feed_items' do
        action
        expect(assigns(:feed_items)).to be_empty
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:stubbed_current_user) do
      allow(controller).to receive(:current_user).and_return(user)
    end
    let(:user) do
      create(:user_with_microposts, microposts_count: 5)
    end
    let(:action) do
      delete :destroy, params: { id: micropost_id }
    end

    before(:each) do
      stubbed_current_user
      logged_in_user_ok
    end

    # default
    let(:micropost_id) { user.microposts[0] }

    describe 'when no microposts' do
      let(:micropost_id) { -1 }
      it 'redirects to root_url' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end

      it 'doesnt delete microposts' do
        expect { action }.to change(Micropost, :count).by(0)
      end
    end

    describe 'when micropost exist' do
      it 'redirect_to root_url' do
        action
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end

      it 'flashes success' do
        action
        expect(flash).not_to be_empty
      end

      it 'delete micropost' do
        expect { action }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe 'check before_action method' do
    controller do
      def create
      end

      def destroy
      end
    end

    let(:stubbed_logged_in?) do
      allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
    end

    describe 'when logged_in_user' do
      before(:each) do
        stubbed_logged_in?
        action
      end

      describe 'when #create' do
        let(:action) do
          post :create, params: {}, session: {}
        end
        let(:logged_in_flag) { false }
        it 'flash before #update if login fails' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq root_url + 'microposts'
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end

      describe 'when #destroy' do
        let(:action) do
          delete :destroy, params: { id: 0 }
        end
        let(:logged_in_flag) { false }
        it 'flash before #update if login fails' do
          expect(flash[:danger]).to be
        end

        it 'stored forwarding_url in session' do
          expect(session[:forwarding_url]).to eq root_url + 'microposts/0'
        end

        it 'redirects login path if login fails' do
          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to('/login')
        end
      end
    end
  end
end
