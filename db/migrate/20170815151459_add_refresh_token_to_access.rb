class AddRefreshTokenToAccess < ActiveRecord::Migration[5.1]
  def change
    add_column :accesses, :refresh_token, :string
    add_column :accesses, :omni_hash, :text
  end
end
