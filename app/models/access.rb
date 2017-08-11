class Access < ApplicationRecord

  belongs_to :user

  validates_presence_of :user_id, :provider, :uid, :email, :name, :state, :code, :token
  validates_uniqueness_of :uid, :scope => :provider
  validates_uniqueness_of :email, :scope => :provider

  # Note: should add more validations when clear what exactly is required for document access

  scope :match_user_id, ->(user_id) { where(user_id: user_id) }
  scope :match_provider_uid, ->(provider, uid) { where(provider: provider, uid: uid) }
  # match by email may not work for some providers
  scope :match_provider_email, ->(provider, email) { where(provider: provider, email: email) }

end
