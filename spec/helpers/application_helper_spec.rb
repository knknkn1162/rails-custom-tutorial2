require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe 'full_title test' do
    it 'doesnt cotain arguments' do
      expect(helper.full_title).not_to include('|')
    end

    it 'contains 1 argument' do
      expect(helper.full_title('Home')).to include('|')
      expect(helper.full_title('Home')).to include('Home')
    end
  end
end
