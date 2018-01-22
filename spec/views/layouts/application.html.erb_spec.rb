require 'rails_helper'

RSpec.describe "layouts/application", type: :view do
  it 'displays title' do
    page_title = 'Sample'
    # TODO: seem to be better!
    inline = "<% provide(:title, '#{page_title}') %>"
    render inline: inline, layout: 'layouts/application'

    expect(rendered).to include full_title(page_title)
  end
end