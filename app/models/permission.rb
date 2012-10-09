class Permission < ActiveRecord::Base
  has_many :group_permissons
  has_many :groups, :through => :group_permissions
  
  def ==(another_permission)
    self.code == another_permission.code
  end
end
