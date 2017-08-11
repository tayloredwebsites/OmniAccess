require 'test_helper'
require 'test_omniauth_helper'

class AccessesControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @user1 = FactoryGirl.create(:user)
    @user1.confirm
    sign_in @user1
    @access1 = FactoryGirl.create(:access, :google_oauth2)
    Rails.logger.debug("+++ setup completed +++")
  end

  test "should get accesses index" do
    get accesses_url
    assert_response :success
  end

  test "should show access" do
    get access_url(@access1)
    assert_response :success
  end

  test "should not create access if no params" do
    assert_difference('Access.count', 0) do
      post accesses_url, params: { access: {  } }
    end
    # confirm @access sent to view got an error
    assert_not_equal(0, assigns(:access).errors.count)
    assert_response :success
    assert_template 'accesses/show'
  end

  test "should destroy access" do
    assert_difference('Access.count', -1) do
      delete access_url(@access1)
    end
    assert_response :success
    assert_template 'accesses/index'
  end

  test "should accept Omniauth mock_auth parameters" do
    assert_difference('Access.count', 1) do
      TestOmniauthHelper.set_valid_google_mock
      # need to set state and code to get these from omniauth mock
      # note these will not be regular params but in request.env['omniauth.params']
      get '/auth/google_oauth2?state=12356754345&code=98730978597324893468923648'
      assert_response :redirect
      assert_redirected_to('http://www.example.com/auth/google_oauth2/callback')
      follow_redirect! # tell controller test to follow redirect!
      assert_template 'accesses/index'
      TestOmniauthHelper.clear_google_mock
    end
  end

  test "should reject missing Omniauth mock_auth parameters" do
    assert_difference('Access.count', 0) do
      TestOmniauthHelper.set_valid_google_mock
      # not setting state and code to get these from omniauth mock
      # causing missing parameters
      # Note: should fine tune what exact parameters are required for full operations.
      # Note: permitted parameter returned always seems to be false, even if authorized, what is this?
      get '/auth/google_oauth2' #?state=12356754345&code=98730978597324893468923648
      assert_response :redirect
      assert_redirected_to('http://www.example.com/auth/google_oauth2/callback')
      follow_redirect! # tell controller test to follow redirect!
      assert_template 'accesses/show'
      TestOmniauthHelper.clear_google_mock
    end
  end

  test "should ignore Omniauth mock :invalid_credentials" do
    assert_difference('Access.count', 0) do
      # force a failure with omniauto mock, see:
      # https://github.com/omniauth/omniauth/wiki/Integration-Testing#user-content-mocking-failure
      TestOmniauthHelper.set_invalid_google_mock
      # need to set state and code to get these from omniauth mock
      # note these will not be regular params but in request.env['omniauth.params']
      get '/auth/google_oauth2?state=12356754345&code=98730978597324893468923648'
      # confirm that we get no response back from google oauth2
      assert_template {[]}
      TestOmniauthHelper.clear_google_mock
    end
  end


end
