
Rails.application.config.middleware.use OmniAuth::Builder do
  secrets = Rails.application.secrets
  provider :google_oauth2,
    secrets.google_client_id,
    secrets.google_client_secret,
    {
      :scope => Rails.configuration.google_oauth_readonly_scope,
      # added access_type offline and prompt consent to also return refresh token
      :access_type => 'offline',
      :prompt => 'consent'
    }
end
