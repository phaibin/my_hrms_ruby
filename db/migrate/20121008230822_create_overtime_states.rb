class CreateOvertimeStates < ActiveRecord::Migration
  def change
    create_table :overtime_states do |t|
      t.string :code
      t.string :name

      t.timestamps
    end
  end
end
