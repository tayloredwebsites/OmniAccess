require 'test_helper'

class AccessTest < ActiveSupport::TestCase

  setup do
    @user1 = FactoryGirl.create(:user)
    @access1 = build_access_record
    Rails.logger.debug("+++ setup completed +++")
  end

  test "access missing user_id should fail" do
    @access1.user_id = nil
    refute @access1.valid?, 'missing user_id should not be valid'
  end

  test "access missing provider should fail" do
    @access1.provider = ''
    refute @access1.valid?, 'missing provider should not be valid'
  end

  test "access missing uid should fail" do
    @access1.uid = ''
    refute @access1.valid?, 'missing uid should not be valid'
  end

  test "access missing email should fail" do
    @access1.email = ''
    refute @access1.valid?, 'missing email should not be valid'
  end

  test "access fully populated should be valid" do
    assert @access1.valid?, 'fully populated access should be valid'
  end

  def build_access_record
    rec = Access.new()
    rec.user_id = @user1.id
    rec.provider = 'google_oauth2'
    rec.uid = 'uid3435324'
    rec.email = 'email123124@sample.com'
    rec.name = 'namelsdflas sdfkljasd'
    rec.state = 'statel;sjdulkjsdf'
    rec.code = 'codeqjdsflk.dsljfdgdsfg'
    rec.expires = true
    rec.expires_at = 2348239
    rec.token = 'tokendslfkj4ou7ujheroi;iudfg;lhjk'
    return rec
  end


end
