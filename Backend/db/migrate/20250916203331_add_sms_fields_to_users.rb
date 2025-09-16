class AddSmsFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone_number, :string
    add_column :users, :sms_verification_enabled, :boolean, default: false
    add_column :users, :sms_verification_code, :string
    add_column :users, :sms_code_expires_at, :datetime
    add_column :users, :phone_verified_at, :datetime

    add_index :users, :phone_number, unique: true
  end
end
