require 'rails_helper'

RSpec.describe 'users/edit', type: :view do
  before(:each) do
    assign(:user, build(:user))
  end
  it 'displays title' do
    render template: 'users/edit', layout: 'layouts/application'
    expect(rendered).to have_title full_title('Edit user')
  end

  it 'renders form partial' do
    render
    expect(rendered).to render_template partial: 'users/_form'
    expect(rendered).to render_template partial: 'shared/_error_messages'
  end

  it 'renders gravatar edit' do
    render
    expect(rendered).to have_selector('div.gravatar_edit img')
    expect(rendered).to have_selector('div.gravatar_edit a', text: 'change')
  end
end
