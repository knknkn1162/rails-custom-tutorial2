require 'rails_helper'

RSpec.describe MicropostsController, type: :controller do
  let(:stubbed_current_user) do
    allow(controller).to receive(:current_user).and_return(user)
  end

  # stub before_action
  let(:stubbed_logged_in_user) do
    allow(controller).to receive(:logged_in_user).and_return(logged_in_flag)
  end

  # default
  let(:logged_in_flag) { true }

  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:micropost) { build(:micropost) }

    let(:action) do
      post :create, params: {
        micropost: { content: content }
      }, session: {}
    end

    # default
    let(:content) { micropost.content }

    before(:each) do
      stubbed_logged_in_user
      stubbed_current_user
    end

    context 'when before_action calls' do
      it 'calls logged_in_user' do
        expect(controller).to receive(:logged_in_user)
        action
      end
    end

    context 'when success' do
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

    context 'when failure' do
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
    let(:user) do
      create(:user_with_microposts, microposts_count: 2)
    end

    let(:action) do
      delete :destroy, params: { id: micropost_id }
    end

    before(:each) do
      stubbed_current_user
      stubbed_logged_in_user
    end

    # default
    let(:micropost_id) { user.microposts[0] }

    context 'when before_action calls' do
      it 'calls logged_in_user' do
        expect(controller).to receive(:logged_in_user)
        action
      end
    end

    context 'when no microposts' do
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

    context 'when micropost exist' do
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

  context 'check logged_in_user method' do
    # NOTE: If using `controller.send(:logged_in_user)`, Module::DelegationError occurs at `redirect_to login_url`. Define anonymous controller instead!
    controller do
      def create; end
    end
    before(:each) do
      stubbed_logged_in?
    end

    let(:action) do
      post :create, params: {}, session: {}
    end

    let(:stubbed_logged_in?) do
      allow(controller).to receive(:logged_in?).and_return(logged_in_flag)
    end

    # default
    let(:logged_in_flag) { false }

    context 'when logged in' do
      before(:each) { action }
      it 'flashes danger' do
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

    context 'when not logged_in' do
      let(:logged_in_flag) { true }
      it 'has #create calls' do
        expect(controller).to receive(:create)
        action
      end
    end
  end
end
