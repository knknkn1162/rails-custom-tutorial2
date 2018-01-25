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
end
