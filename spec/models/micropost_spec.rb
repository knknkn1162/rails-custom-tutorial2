require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let(:user) { create(:user) }
  context 'when validation check' do
    let(:micropost) do
      build(:micropost, content: content, user: user)
    end

    # default
    let(:content) { attributes_for(:micropost)[:content] }

    it 'should be valid' do
      expect(micropost).to be_valid
    end

    context 'when invalid name contains' do
      context 'when nil user ' do
        let(:user) { nil }
        it 'should have non-empty user' do
          expect(micropost).not_to be_valid
        end
      end

      context 'when blank content' do
        let(:content) { ' ' }
        it 'should be present' do
          expect(micropost).not_to be_valid
        end
      end

      context 'when content should be at most 140 characters' do
        let(:content) { 'a' * 141 }
        it 'should be at least 140 characters' do
          expect(micropost).not_to be_valid
        end
      end
    end
  end

  context 'when order by created_at descendingly' do
    let(:micropost_most_recent) { create(:micropost, user: user) }
    before(:each) do
      create_list(:micropost, 5, user: user, created_at: 3.hours.ago)
      micropost_most_recent
      create(:micropost, user: user, created_at: 2.hours.ago)
    end

    it 'should be most recent micropost first' do
      expect(Micropost.first).to eq micropost_most_recent
    end
  end
end
