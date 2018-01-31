require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'account_activation' do
    let(:user) { build(:user, activation_token: 'sample_activation_token') }
    let(:mail) { UserMailer.account_activation(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Account activation')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match(user.name)
      activation_url = root_url + "account_activations/#{user.activation_token}/edit" + "?email=#{CGI.escape(user.email)}"
      expect(mail.body.encoded).to have_link(href: activation_url, text: 'Activate')
      # text only
      expect(mail.body.encoded).to have_content(activation_url, count: 1)
    end
  end

  # describe 'password_reset' do
    # let(:mail) { UserMailer.password_reset }

    # it 'renders the headers' do
      # expect(mail.subject).to eq('Password reset')
      # expect(mail.to).to eq(['to@example.org'])
      # expect(mail.from).to eq(['from@example.com'])
    # end

    # it 'renders the body' do
      # expect(mail.body.encoded).to match('Hi')
    # end
  # end
end
