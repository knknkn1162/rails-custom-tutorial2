require 'rails_helper'

RSpec.describe 'shared/_error_messages', type: :view do
  it 'displays multiple errors' do
    # 'The form contains 3 errors.
    user = User.create(
      name: 'dummy',
      email: ' ',
      password: 'aaabbb',
      password_confirmation: 'bbbccc'
    )

    msgs = user.errors.full_messages
    expect(msgs).not_to be_empty
    render partial: 'shared/error_messages', locals: { model: user }
    msgs.each do |msg|
      expect(rendered).to have_selector('li', text: msg)
    end
  end

  it 'displays alert when single errors' do
    user = User.create(attributes_for(:user, password_confirmation: 'dummy'))
    msgs = user.errors.full_messages
    expect(msgs.size).to eq 1
    render partial: 'shared/error_messages', locals: { model: user }
    expect(rendered).to have_content 'error'
    expect(rendered).not_to have_content 'errors'
  end
end
