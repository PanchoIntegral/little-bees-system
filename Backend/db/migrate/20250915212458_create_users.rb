class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :role, null: false, default: 'employee'
      t.string :encrypted_password, null: false
      t.string :two_factor_secret
      t.boolean :two_factor_enabled, default: false
      t.string :phone
      t.datetime :last_sign_in_at
      t.datetime :current_sign_in_at
      t.integer :sign_in_count, default: 0

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
