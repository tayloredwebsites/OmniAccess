require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def sign_in_user_before
    @one = create(:user)
    @one.confirm
    sign_in @one
  end

  test "should get home index" do
    sign_in_user_before
    get home_index_url
    assert_response :success
  end

  def test_should_get_home_index_method
    sign_in_user_before
    get home_index_url
    assert_response :success
  end

end
