
Rails.application.config.middleware.use OmniAuth::Builder do
  secrets = Rails.application.secrets
  oauth_scope = 'userinfo.email, userinfo.profile, https://www.googleapis.com/auth/drive.readonly'
  provider :google_oauth2, secrets.google_client_id, secrets.google_client_secret, { :scope => oauth_scope }
end
