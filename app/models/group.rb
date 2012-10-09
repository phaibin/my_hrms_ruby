class Group < ActiveRecord::Base
  has_many :users, :through => :user_groups
  has_many :group_permissions
  has_many :permissions, :through => :group_permissions
  
  def ==(another_group)
    self.name == another_group.name
  end
end
