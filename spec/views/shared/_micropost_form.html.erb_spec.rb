require 'rails_helper'

RSpec.describe 'shared/_micropost_form', type: :view do
  before(:each) do
    assign(:micropost, Micropost.new)
    render 'shared/micropost_form'
  end

  it 'has partial page, _error_messages' do
    expect(rendered).to render_template('shared/_error_messages')
  end

  it 'has text area and button' do
    expect(rendered).to have_field
    expect(rendered).to have_button 'Post'
  end
end
