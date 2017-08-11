class CreateAccesses < ActiveRecord::Migration[5.1]
  def change
    create_table :accesses do |t|
      t.references :user
      t.string :provider
      t.string :uid
      t.string :email
      t.string :name
      t.string :state
      t.string :code
      t.string :token
      t.boolean :expires
      t.datetime :expires_at

      t.timestamps

      t.index [:provider, :uid], unique: true
      t.index [:provider, :email], unique: true
    end
  end
end
