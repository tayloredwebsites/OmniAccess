class RemoteFilesController < ApplicationController
  require 'google/apis/drive_v3'

  # GET /remote_files/1
  # Route:   get 'remote_files/:access_id', => 'remote_files#index'
  def index

    @access = Access.find(params['access_id'])

    gdriveService = Google::Apis::DriveV3::DriveService.new
    gdriveService.client_options.application_name = 'OmniAccess'

    # prevent 'Missing token endpoint URI.' on list_files api call
    # removed these:
    # authorization = Signet::OAuth2::Client.new(access_token: access.token)
    # gdriveService.authorization = authorization
    #
    # see client code at: https://github.com/google/signet/blob/master/lib/signet/oauth_2/client.rb
    # client = Signet::OAuth2::Client.new(
    #   :client_id => Rails.application.secrets.google_client_id,
    #   :client_secret => Rails.application.secrets.google_client_secret,
    #   :scope => Rails.configuration.google_oauth_readonly_scope,
    #   :token => @access.token,
    #   :refresh_token => @access.refresh_token,
    #   :access_type => 'offline',
    #   :prompt => 'consent'
    # )
    # gdriveService.authorization = client

    # prevent 'Missing token endpoint URI.' on list_files api call
    access_token = SetGoogleToken.new(@access.token)
    gdriveService.authorization = access_token


    # see list_files code at: https://github.com/google/google-api-ruby-client/blob/master/generated/google/apis/drive_v3/service.rb

    # ToDo: should probably not pass next_page_token as query string in get.
    nxt_pg_token = params['next_page_token']
    begin
      resp = list_next_gdrive_files(gdriveService, nxt_pg_token)
    rescue => e
      Rails.logger.error("ERROR: captured exception on list files: #{e.to_s}")
      # get a new access token from the refresh token right now!
      refresh_google_access_token()
      resp = list_next_gdrive_files(gdriveService, nxt_pg_token)
    end

    @files = resp.files
    @next_page_token = resp.next_page_token
  end

  private


    # Never trust parameters from the scary internet, only allow the white list through.
    def access_params
      params.fetch(:access, {})
    end

    # prevent 'Missing token endpoint URI.' on list_files api call
    # per: https://stackoverflow.com/questions/38089763/missing-token-endpoint-uri-while-using-a-valid-access-token
    # and:https://github.com/google/google-api-ruby-client/issues/296
    class SetGoogleToken
      attr_reader :token
      def initialize(token)
        @token = token
      end

      def apply!(headers)
        headers['Authorization'] = "Bearer #{@token}"
      end
    end

    # go to next page of files if passed the next page token
    def list_next_gdrive_files(gdriveService, nxt_pg_token)
      if nxt_pg_token.present?
        resp = gdriveService.list_files(page_size: 10, fields: 'nextPageToken, files(id, name)', page_token: nxt_pg_token)
      else
        resp = gdriveService.list_files(page_size: 10, fields: 'nextPageToken, files(id, name)')
      end
    end

    # update the access token from the refresh token
    def refresh_google_access_token()
      @response = HTTParty.post('https://accounts.google.com/o/oauth2/token', {
        body: {
          client_id: Rails.application.secrets.google_client_id,
          client_secret: Rails.application.secrets.google_client_secret,
          refresh_token: @access.refresh_token,
          grant_type: 'refresh_token'
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded'
        }
      })
      if @response.code == 200
        @access.token = @response.parsed_response['access_token']
        # get timestamp from expires_at in unix seconds since epoch ( January 1, 1970 - midnight UTC/GMT )
        expires_at_i = Integer(@response.parsed_response['expires_at']) rescue 0
        @access.expires_at = expires_at_i > 0 ? Time.at(expires_at_i).utc.to_datetime : nil
        @access.save
      else
        Rails.logger.error("Unable to refresh google_oauth2 authentication token.")
        Rails.logger.error("Refresh token response body: #{@response.body}")
        raise "Unable to refresh google_oauth2 authentication token."
      end
    end

end
