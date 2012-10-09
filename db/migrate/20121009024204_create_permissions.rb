class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
