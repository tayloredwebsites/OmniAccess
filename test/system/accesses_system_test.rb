require 'application_system_test_case'
require 'test_omniauth_helper'

class AccessesSystemTest < ApplicationSystemTestCase

  include Devise::Test::IntegrationHelpers

  setup do
    @user1 = FactoryGirl.create(:user)
    @user1.confirm
    sign_in @user1
    @access1 = FactoryGirl.create(:access, :google_oauth2, user: @user1)
    Rails.logger.debug("+++ setup completed +++")
  end

  test "index of accesses with show and destroy working" do
    visit accesses_url
    assert_equal("/accesses", current_path)
    assert_equal(1, page.all('tr.userAccess').count)
    # show this access
    page.find("td.show a").click
    within('h1') { assert page.has_content?('View Account Accessed Details') }
    visit accesses_url
    assert_equal("/accesses", current_path)
    assert_equal(1, page.all('tr.userAccess').count)
    # delete this access
    page.find("td.destroy a").click
    # click OK in javascript confirmation popup
    page.driver.browser.switch_to.alert.accept
    within('h1') { assert page.has_content?("Accesses for user: #{@user1.email}") }
    assert_equal(0, page.all('tr.userAccess').count)
  end


  test "authentication works with manuak adjusted url" do
    visit accesses_url
    assert_equal("/accesses", current_path)
    assert_equal(1, page.all('tr.userAccess').count)
    TestOmniauthHelper.set_valid_google_mock
    visit '/auth/google_oauth2?state=12356754345&code=98730978597324893468923648'
    TestOmniauthHelper.clear_google_mock
    # confirm on the listing page with the successful addition listed
    assert_equal("/auth/google_oauth2/callback", current_path)
    within('h1') { assert page.has_content?("Accesses for user: #{@user1.email}") }
    assert_equal(2, page.all('tr.userAccess').count)
  end

  test "Note: mock authentication fails from standard link" do
    visit accesses_url
    assert_equal("/accesses", current_path)
    TestOmniauthHelper.set_valid_google_mock
    page.find("a[href='/auth/google_oauth2']").click
    TestOmniauthHelper.clear_google_mock
    # Confirm on the view access error page
    within('h1') { assert page.has_content?("View Account Accessed Details") }
    within('#error_explanation') { assert page.has_content?('2 errors prohibited this access from being saved:') }
  end

  test "invalid mock authentication fails" do
    TestOmniauthHelper.set_invalid_google_mock
    visit('/auth/google_oauth2?state=12356754345&code=98730978597324893468923648')
    TestOmniauthHelper.clear_google_mock
    # Confirm on the view access error page
    within('h1') { assert page.has_content?("View Account Accessed Details") }
    # confirm we got invalid credentials returned
    within('#error_explanation') do
      assert page.has_content?('1 error prohibited this access from being saved:')
      assert_equal( page.all('ul li')[0].text, 'invalid credentials')
    end
  end

end
