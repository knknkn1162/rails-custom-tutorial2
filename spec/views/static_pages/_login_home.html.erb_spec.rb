require 'rails_helper'

RSpec.describe 'static_pages/_login_home', type: :view do
  let(:stubbed_current_user) do
    allow(view).to receive(:current_user).and_return(create(:user))
  end

  before(:each) do
    stubbed_current_user
    assign(:micropost, Micropost.new)
    render
  end

  it 'has partial page, _error_messages' do
    expect(rendered).to render_template('shared/_user_info')
    expect(rendered).to render_template('shared/_micropost_form')
  end
end
