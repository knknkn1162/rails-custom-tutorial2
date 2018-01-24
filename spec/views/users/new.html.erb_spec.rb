require 'rails_helper'

RSpec.describe 'users/new.html.erb', type: :view do
  before(:each) do
    assign(:user, build(:user))
  end
  it 'displays title' do
    render template: 'users/new', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Sign up')
  end

  it 'renders form partial' do
    render
    expect(rendered).to render_template partial: 'users/_form'
    expect(rendered).to render_template partial: 'shared/_error_messages'
  end
end
