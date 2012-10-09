class CreateUserOvertimes < ActiveRecord::Migration
  def change
    create_table :user_overtimes do |t|
      t.references :user
      t.references :overtime

      t.timestamps
    end
    add_index :user_overtimes, :user_id
    add_index :user_overtimes, :overtime_id
  end
end
