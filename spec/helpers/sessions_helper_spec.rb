require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the SessionsHelper. For example:
#
# describe SessionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe SessionsHelper, type: :helper do
  describe 'log_in test' do
    it 'tests login' do
      user = instance_double('User', id: 10)
      helper.log_in(user)
      expect(session[:user_id]).to eq 10
    end
  end

  describe 'current_user test' do
    it 'tests current_user' do
      user = create(:user)
      session[:user_id] = user.id
      helper.current_user
      # TODO: unavailable to use assigns method after adding `rails-controller-testing` gem
      current_user = helper.instance_variable_get(:@current_user)
      expect(current_user).to eq user
    end
  end

  describe 'logged_in? test' do
    it 'should be true when log_in' do
      user = create(:user)
      session[:user_id] = user.id
      expect(helper.logged_in?).to be_truthy
    end
    it 'should be false when not log_in' do
      session[:user_id] = -1
      expect(helper.logged_in?).to be_falsy
    end
  end
end
