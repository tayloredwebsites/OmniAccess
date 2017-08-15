class AccessesController < ApplicationController
  before_action :set_access, only: [:show, :destroy]

  # GET /accesses
  def index
    @accesses = Access.match_user_id(current_user.id)
  end

  # GET /accesses/1
  def show
  end

  # POST /accesses
  # handler for callback from omniauth ( as well as failure callback)
  # always generate an access model for error display.
  def create
    # make sure all parameters needed for access record are there
    # Rails.logger.debug("*** AccessController#create params: #{params.inspect}")
    # Rails.logger.debug("*** `request.env['omniauth.auth']: #{request.env['omniauth.auth'].inspect}")
    begin
      # check if record exists already or failure
      access = get_or_create_rec(params, request)
      # if failure callback, do not populate the record from the returned params
      if access.errors[:base].include?("invalid credentials")
        @access = access
      else
        @access = populate_access_rec(access, params, request)
      end
      # if no errors already, validate and save it
      if @access.errors.count == 0 && @access.valid?
        if @access.new_record?
          action = 'Created'
        else
          action = 'Updated'
        end
        @access.save
      else
        action = 'Not Updated'
      end
    end
    Rails.logger.debug("*** errors: #{@access.errors.inspect}")
    respond_to do |format|
      if @access.errors.count == 0
        # succesful add or update, display the listing page
        @accesses = Access.match_user_id(current_user.id)
        flash[:notice] = "Access was successfully #{action}."
        format.html { render :index }
      else
        # errors, display the show page with errors.
        Rails.logger.error("ERROR: create response got: #{@access.errors.full_messages}") if @access.present?
        flash[:alert] = 'Access was not created - see errors.'
        format.html { render :show }
      end
    end
  end

  # DELETE /accesses/1
  def destroy
    respond_to do |format|
      if @access.destroy
        @accesses = Access.match_user_id(current_user.id)
        format.html { render :index, notice: 'Access was successfully destroyed.' }
      else
        format.html { render :show, alert: 'Access was not destroyed.' }
      end
    end
  end

  private

    # common setup for current access
    def set_access
      @access = Access.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def access_params
      params.fetch(:access, {})
    end

    # read existing record or create new access record, and then check for key consistency
    def get_or_create_rec(params, request)
      if /invalid_credentials/.match(params['message'])
        # invalid credentials failure (from failure callback)
        Rails.logger.error("*** invalid credentials")
        ret = Access.new
        ret.provider = params['strategy']
        ret.errors.add(:base, "invalid credentials")
        return ret
      else
        # not a failure callback process it.
        omni_hash = request.env['omniauth.auth']
        provider = params['provider'] rescue nil
        uid = omni_hash[:uid] rescue nil
        email = omni_hash[:info][:email] rescue nil
        # look up this authorization via two scopes, and confirm they are the same record
        matching_uids = Access.match_provider_uid(params['provider'], uid)
        matching_emails = Access.match_provider_email(params['provider'], email)
        # Key consistency checks
        if matching_uids.count == 0 && matching_emails.count == 0
          # no matching records in database, return a new record
          return Access.new
        elsif matching_uids.count == 1 &&
          matching_emails.count == 1 &&
          matching_uids.first.id == matching_emails.first.id
          # record is same from both lookups
          return matching_uids.first
        else
          # mismatched records in database return one with error
          ret = matching_emails.first
          ret.errors.add(:base, "Mismatched lookups by uid: #{uid.inspect} and email: #{email.inspect}")
          return ret
        end
      end
    end

    # build the access record from the various param and request values
    # mark model field with error, if nil error getting the parameter for it
    def populate_access_rec(rec, params, request)
      omni_hash =  request.env['omniauth.auth']
      if rec.new_record?
        # put in key values for new record
        rec.user_id = current_user.id rescue rec.errors.add(:user_id, 'missing current_user.id parameters')
        rec.provider = params['provider']
        rec.uid = omni_hash[:uid] rescue rec.errors.add(:uid, 'missing uid parameters')
        rec.email = omni_hash[:info][:email] rescue rec.errors.add(:email, 'missing [:info][:email] parameters')
      else
        # comparison key values obtained safely
        user_id = current_user.id rescue nil
        provider = params['provider'] rescue nil
        uid = omni_hash[:uid] rescue nil
        email = omni_hash[:info][:email] rescue nil
        # confirm no change in key fields
        rec.errors.add(:user_id, "does not match #{user_id.inspect}") if rec.user_id != user_id
        rec.errors.add(:provider, "does not match #{provider.inspect}e") if rec.provider != provider
        rec.errors.add(:uid, "does not match #{uid.inspect}") if rec.uid != uid
        rec.errors.add(:email, "does not match #{email.inspect}")if rec.email != email
      end
      rec.name = omni_hash[:info][:name] rescue rec.errors.add(:name, 'missing [:info][:name] parameters')
      # hack to get omniauth mock to pass the state and code values
      if Rails.env.test?
        omni_params =  request.env['omniauth.params']
        rec.state = omni_params['state'] rescue rec.errors.add(:state, 'missing mock state parameters')
        rec.code = omni_params['code'] rescue rec.errors.add(:code, 'missing mock code parameters')
      else
        rec.state = params['state']
        rec.code = params['code']
      end
      rec.expires = omni_hash[:credentials][:expires] rescue nil
      rec.expires_at = nil
      if rec.expires
        # get timestamp from expires_at in unix seconds since epoch ( January 1, 1970 - midnight UTC/GMT )
        expires_at_i = Integer(omni_hash[:credentials][:expires_at]) rescue 0
        rec.expires_at = Time.at(expires_at_i).utc.to_datetime if expires_at_i > 0
      end
      rec.token = omni_hash[:credentials][:token] rescue rec.errors.add(:name, 'missing [:credentials][:token] parameters')
      rec.refresh_token = omni_hash[:credentials][:refresh_token] rescue nil # OK if no refresh token
      rec. omni_hash = omni_hash
      return rec
    end

end
