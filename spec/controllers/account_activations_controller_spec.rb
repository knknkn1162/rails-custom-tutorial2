require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  describe 'GET #edit' do
    let(:user) {
      create(:user, activated: false, activated_at: nil)
    }
    let(:stubbed_activated?) do
      # will allow you to stub or mock any instance of a class.
      allow_any_instance_of(User).to receive(:activated?).and_return(activated_flag)
    end
    # REVIEW: cannot be authenticated? method stubbed?
    let(:stubbed_authenticated?) do
      allow_any_instance_of(User).to receive(:authenticated?).and_return(authenticated_flag)
    end

    let(:get_edit) do
      get :edit, params: { id: user.activation_token, email: user.email }, session: {}
    end

    let(:expect_redirect_to_root) do
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to('/')
    end

    let(:expect_flashes_danger) do
      expect(flash[:danger]).to be
    end

    describe 'when user is not valid' do
      before(:each) do
        get :edit, params: { id: user.id, email: 'dummy' }, session: {}
      end
      it 'redirects to root_path when email is invalid' do
        expect_redirect_to_root
      end

      it 'flashes danger' do
        expect_flashes_danger
      end
    end

    describe 'when activated' do
      let!(:activated_flag) { true }
      before(:each) do
        stubbed_activated?
        get_edit
      end

      it 'redirects to root_path' do
        expect_redirect_to_root
      end

      it 'flashes danger' do
        expect_flashes_danger
      end
    end

    describe 'when un-authenticated' do
      let!(:authenticated_flag) { false }
      before(:each) do
        stubbed_authenticated?
        get_edit
      end

      it 'redirects to root_path' do
        expect_redirect_to_root
      end

      it 'flashes danger' do
        expect_flashes_danger
      end
    end

    describe 'when user is unactivated yet & authorized' do
      let!(:authenticated_flag) { true }
      let!(:activated_flag) { false }

      before(:each) do
        #stubbed_activated?
        #stubbed_authenticated?
        get_edit
      end

      it 'redirects to :show' do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to("/users/#{user.id}")
      end

      it 'flashes success' do
        expect(flash[:success]).to be
      end

      it 'update activated & activated_at attribute' do
        user.reload
        expect(user.activated).to be_truthy
        expect(user.activated_at).to be
      end

      it 'stores session' do
        expect(session).not_to be_empty
      end
    end
  end
end
