require 'rails_helper'

RSpec.describe AccountActivationsController, type: :controller do
  before(:each) do
    user
    action
  end

  describe 'GET #edit' do
    let(:user) do
      # REVIEW: how to mock user object? The allow_any_instance_of method is a bit stable thing..
      allow_any_instance_of(User).to receive(:authenticated?).and_return(authenticated_flag)
      create(:user, activated: activated_flag, activated_at: nil)
    end

    let(:action) do
      get :edit, params: { id: activation_token, email: email }, session: {}
    end

    # default
    let(:activated_flag) { false } # unactivated
    let(:authenticated_flag) { true }
    let(:activation_token) { user.activation_token }
    let(:email) { user.email }

    context 'when invalid' do
      # expectation
      let(:expect_redirect_to_root) do
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to('/')
      end

      let(:expect_flashes_danger) do
        expect(flash[:danger]).to be
      end

      context 'when user is not valid' do
        let(:email) { 'dummy' }
        it 'redirects to root_path when email is invalid' do
          expect_redirect_to_root
        end
        it 'flashes danger' do
          expect_flashes_danger
        end
      end

      context 'when activated' do
        let(:activated_flag) { true }
        it 'redirects to root_path' do
          expect_redirect_to_root
        end
        it 'flashes danger' do
          expect_flashes_danger
        end
      end

      context 'when un-authenticated' do
        let(:authenticated_flag) { false }
        it 'redirects to root_path' do
          expect_redirect_to_root
        end
        it 'flashes danger' do
          expect_flashes_danger
        end
      end
    end

    context 'when user is unactivated yet & authorized' do
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
