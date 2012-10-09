class CreateOvertimeFlows < ActiveRecord::Migration
  def change
    create_table :overtime_flows do |t|
      t.references :overtime
      t.integer :applicant_id
      t.integer :parent_id
      t.boolean :can_read
      t.boolean :can_update
      t.boolean :can_delete
      t.boolean :can_apply
      t.boolean :can_revoke
      t.boolean :can_reject
      t.boolean :can_approve

      t.timestamps
    end
    add_index :overtime_flows, :overtime_id
  end
end
