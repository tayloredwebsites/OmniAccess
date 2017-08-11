OmniAuth.config.test_mode = true

class TestOmniauthHelper

  def self.set_valid_google_mock
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      :provider => 'google_oauth2',
      :uid => '123545123545',
      :info => OmniAuth::AuthHash.new({
        :email => "testing@sample.com",
        :name => "OAuth User Name"
      }),
      :credentials => OmniAuth::AuthHash.new({
        :expires => true,
        :expires_at => '12124w45',
        :token => "asdnfskdyopweurtoisdhgf;oadsihfg;dshgvkadsjhfg234534534"
      })
    })
  end

  def self.set_invalid_google_mock
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
  end

  def self.clear_google_mock
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end

end
