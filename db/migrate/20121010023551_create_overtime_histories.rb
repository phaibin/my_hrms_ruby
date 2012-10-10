class CreateOvertimeHistories < ActiveRecord::Migration
  def change
    create_table :overtime_histories do |t|
      t.references :overtime
      t.integer :modified_by
      t.references :overtime_state

      t.timestamps
    end
    add_index :overtime_histories, :overtime_id
    add_index :overtime_histories, :overtime_state_id
  end
end
