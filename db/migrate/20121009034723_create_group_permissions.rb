class CreateGroupPermissions < ActiveRecord::Migration
  def change
    create_table :group_permissions do |t|
      t.references :group
      t.references :permission

      t.timestamps
    end
    add_index :group_permissions, :group_id
    add_index :group_permissions, :permission_id
  end
end
