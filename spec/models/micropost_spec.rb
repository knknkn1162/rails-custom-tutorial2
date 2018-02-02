require 'rails_helper'

RSpec.describe Micropost, type: :model do
  describe 'when validation check' do
    let(:micropost) do
      build(:micropost, content: content, user_id: user_id )
    end

    let(:user) { create(:user) }
    # default
    let(:user_id) { user.id }
    let(:content) { attributes_for(:micropost)[:content] }

    it 'should be valid' do
      expect(micropost).to be_valid
    end

    context 'when invalid name contains' do
      describe 'when should have non-empty user ' do
        let(:user_id) { nil }
        it 'should have non-empty user' do
          expect(micropost).not_to be_valid
        end
      end

      describe 'content should be present' do
        let(:content) { ' ' }
        it 'should be present' do
          expect(micropost).not_to be_valid
        end
      end

      describe 'context should be at most 140 characters' do
        let(:content) { 'a' * 141 }
        it 'should be at least 140 characters' do
          expect(micropost).not_to be_valid
        end
      end
    end
  end
end
