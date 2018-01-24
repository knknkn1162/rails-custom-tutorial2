require 'rails_helper'

RSpec.describe "layouts/application", type: :view do
  it 'displays title' do
    page_title = 'Sample'
    # TODO: it seems to be better!
    inline = "<% provide(:title, '#{page_title}') %>"
    render inline: inline, layout: 'layouts/application'

    expect(rendered).to have_title full_title(page_title)
  end

  it 'displays single flash' do
    test_sentence = 'This is a test'
    flash[:test1] = test_sentence + '1'
    flash[:test2] = test_sentence + '2'
    render inline: '', layout: 'layouts/application'
    expect(rendered).to have_selector 'div.alert-test1', text: test_sentence + '1'
    expect(rendered).to have_selector 'div.alert-test2', text: test_sentence + '2'
  end
end
