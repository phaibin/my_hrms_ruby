class OvertimeFlow < ActiveRecord::Base
  belongs_to :overtime
  belongs_to :applicant, :class_name => 'User'
  belongs_to :parent, :class_name => 'OvertimeFlow'
  
  # 申请人    
  def set_applicant_state
    self.reset_state
    self.can_read = true
    self.can_revoke = true
  end
    
  # 申请人撤销
  def set_revoke_state
    self.reset_state
    self.can_update = true
    self.can_delete = true
    self.can_apply = true
  end
    
  # 参加人
  def set_viewer_state
    self.reset_state
    self.can_read = true
  end
     
  # 批准过的人
  def set_hidden_state
    self.reset_state
  end
    
  # 审核人
  def set_reviewer_state
    self.reset_state
    self.can_read = true
    self.can_reject = true
    self.can_approve = true
  end
    
  def reset_state
    puts '*' * 10
    puts 'reset_state'
    self.can_read = false
    self.can_update = false
    self.can_delete = false
    self.can_apply = false
    self.can_revoke = false
    self.can_reject = false
    self.can_approve = false
  end
end
