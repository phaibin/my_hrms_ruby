class AddFiledsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :chinese_name, :string
    add_column :users, :english_name, :string
    add_column :users, :superior_id, :integer
  end
end
