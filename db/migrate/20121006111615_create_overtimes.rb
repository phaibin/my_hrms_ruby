class CreateOvertimes < ActiveRecord::Migration
  def change
    create_table :overtimes do |t|
      t.string :subject
      t.datetime :start_time
      t.datetime :end_time
      t.integer :state_id
      t.integer :applicant_id
      t.text :content
      t.integer :modified_by

      t.timestamps
    end
    add_index :overtimes, :applicant_id
    add_index :overtimes, :modified_by
  end
end
