class EnhanceUserSecurity < ActiveRecord::Migration[7.2]
  def change
    # Add security-related fields
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :locked_at, :datetime
    add_column :users, :unlock_token, :string
    add_column :users, :two_factor_backup_codes, :text # JSON array of backup codes
    add_column :users, :password_changed_at, :datetime
    add_column :users, :must_change_password, :boolean, default: false, null: false
    add_column :users, :session_token, :string # For session management
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime

    # Add indexes for performance and security
    add_index :users, :active
    add_index :users, :unlock_token
    add_index :users, :session_token
    add_index :users, :confirmation_token
    add_index :users, :reset_password_token
    add_index :users, :failed_attempts
  end
end
