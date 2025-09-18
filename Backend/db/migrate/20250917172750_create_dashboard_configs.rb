class CreateDashboardConfigs < ActiveRecord::Migration[7.2]
  def change
    create_table :dashboard_configs do |t|
      t.references :user, null: false, foreign_key: true
      t.text :config
      t.string :layout_name, default: 'default'
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :dashboard_configs, [:user_id, :layout_name], unique: true
  end
end
