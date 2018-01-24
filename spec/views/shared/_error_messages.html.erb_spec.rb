require 'rails_helper'

RSpec.describe 'shared/_error_messages', type: :view do
  describe 'when valid user' do
    it 'doesnt contains alert class' do
      user = User.create(attributes_for(:user))
      render partial: 'shared/error_messages', locals: { model: user }

      expect(rendered).not_to have_selector('.alert-danger')
    end
  end

  describe 'when invalid user with a single error' do
    let(:invalid_user) do
      User.create(attributes_for(:user, password_confirmation: 'dummy'))
    end
    before(:each) do
      msgs = invalid_user.errors.full_messages
      expect(msgs.size).to eq 1
      render partial: 'shared/error_messages', locals: { model: invalid_user }
    end

    it 'display singlular word, `1 error`' do
      expect(rendered).to have_content 'error'
      expect(rendered).not_to have_content 'errors'
    end

    it 'contains alert-danger class' do
      expect(rendered).to have_selector('.alert-danger')
    end
  end

  describe 'when invalid user with multiple errors' do
    let(:invalid_user) do
      # 'The form contains 3 errors.
      User.create(
        name: 'dummy',
        email: ' ',
        password: 'aaabbb',
        password_confirmation: 'bbbccc'
      )
    end

    let(:msgs) {
      invalid_user.errors.full_messages
    }

    before(:each) do
      expect(msgs.size).to be > 1
      render partial: 'shared/error_messages', locals: { model: invalid_user }
    end

    it 'displays multiple error messages' do
      msgs.each do |msg|
        expect(rendered).to have_selector('li', text: msg)
      end
    end

    it 'contains alert-danger class' do
      expect(rendered).to have_selector('.alert-danger')
    end
  end
end
