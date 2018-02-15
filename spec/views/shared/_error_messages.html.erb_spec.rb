require 'rails_helper'

RSpec.describe 'shared/_error_messages', type: :view do
  before(:each) do
    render partial: 'shared/error_messages', locals: { model: user }
  end

  context 'when valid user' do
    let(:user) { User.create(attributes_for(:user)) }

    it 'doesnt contains alert class' do
      expect(rendered).not_to have_selector('#error_explanation')
      expect(rendered).not_to have_selector('.alert-danger')
    end
  end

  describe 'when invalid user with a single error' do
    let(:user) do
      User.create(attributes_for(:user, password_confirmation: 'dummy'))
    end

    let(:error_messages) { user.errors.full_messages }

    it 'display singlular word, `1 error`' do
      expect(error_messages.size).to eq 1
      expect(rendered).to have_content 'error'
      expect(rendered).not_to have_content 'errors'
    end

    it 'contains alert-danger class' do
      expect(rendered).to have_selector('#error_explanation')
      expect(rendered).to have_selector('.alert-danger')
    end
  end

  describe 'when invalid user with multiple errors' do
    let(:user) do
      # 'The form contains 3 errors.
      User.create(
        name: 'dummy',
        email: ' ',
        password: 'aaabbb',
        password_confirmation: 'bbbccc'
      )
    end

    let(:error_messages) { user.errors.full_messages }

    before(:each) do
      render partial: 'shared/error_messages', locals: { model: user }
    end

    it 'displays multiple error messages' do
      expect(error_messages.size).to be > 1
      error_messages.each do |msg|
        expect(rendered).to have_selector('li', text: msg)
      end
    end

    it 'contains alert-danger class' do
      expect(rendered).to have_selector('#error_explanation')
      expect(rendered).to have_selector('.alert-danger')
    end
  end
end
