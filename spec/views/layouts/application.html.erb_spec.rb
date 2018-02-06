require 'rails_helper'

RSpec.describe 'layouts/application', type: :view do
  before(:each) do
    store_flashes
    render inline: inline, layout: 'layouts/application'
  end

  # default
  let(:inline) { '' }
  let(:store_flashes) {}

  context 'when title is provided' do
    let(:page_title) { 'Sample' }
    let(:inline) { "<% provide(:title, '#{page_title}') %>" }
    it 'displays title' do
      expect(rendered).to have_title /#{page_title}/
    end
  end

  context 'when provide nothing' do
    let(:sentences) { Faker::Lorem.sentences(2) }
    let(:store_flashes) do
      flash[:test1] = sentences[0]
      flash[:test2] = sentences[1]
    end

    it 'displays flashes' do
      expect(rendered).to have_selector 'div.alert-test1', text: sentences[0]
      expect(rendered).to have_selector 'div.alert-test2', text: sentences[1]
    end
  end
end
