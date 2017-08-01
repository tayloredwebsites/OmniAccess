require 'application_system_test_case'

class HomeSystemTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  def sign_in_user_before
    @one = create(:user)
    @one.confirm
    sign_in @one
  end

  test "should get index" do
    sign_in_user_before
    visit home_index_url
    assert_equal("/home/index", current_path)
  end

  def test_should_get_index_method
    sign_in_user_before
    visit home_index_url
    assert_equal("/home/index", current_path)
  end

end
