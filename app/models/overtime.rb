class Overtime < ActiveRecord::Base
  belongs_to :applicant, :class_name => 'User'
  belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by'
  belongs_to :state, :class_name => 'OvertimeState'
  has_many :user_overtimes
  has_many :participants, :through => :user_overtimes, :source => :user
  has_many :overtime_flows
  has_many :histories, :class_name => 'OvertimeHistory'
      
  validates_presence_of :subject, :on => :create, :message => "can't be blank"
  
  def participants_string
      return self.participants.collect{|x| x.chinese_name}.compact.join(', ')
  end
  
  def self.create_with_flow(user, new_overtime)
    participants = []
    for user_id in new_overtime['participants'].reject!(&:blank?)
      temp_user = User.find(user_id)
      participants.push(temp_user)
    end
    new_overtime['participants'] = participants
    overtime = Overtime.new(new_overtime)
    overtime.state = OvertimeState.find_by_code('ReadyForDirectorApprove')
    overtime.applicant = user
    overtime.modified_by = user
    overtime.save()
      
    # application flow for current user
    current_flow = OvertimeFlow.new
    current_flow.overtime = overtime
    current_flow.applicant = overtime.applicant
    current_flow.set_applicant_state()
    current_flow.save()

    # application flow for participants
    for participant in overtime.participants.all()
      if participant != overtime.applicant
        app_flow = OvertimeFlow.new
        app_flow.overtime = overtime
        app_flow.applicant = participant
        app_flow.set_viewer_state()
        app_flow.save()
      end
    end
    # application flow for superior
    next_flow = OvertimeFlow.new
    next_flow.overtime = overtime
    next_flow.applicant = user.superior
    next_flow.parent = current_flow
    next_flow.set_reviewer_state()
    next_flow.save()
        
    # application history
    overtime.write_history(user)
        
    return overtime
  end
  
  def update_with_flow(user, new_overtime)
    for participant in self.participants
      if participant != self.applicant
        app_flow = self.overtime_flow_by_user(participant)
        if app_flow
          app_flow.delete()
        end
      end
    end
    
    participants = []
    for user_id in new_overtime['participants'].reject!(&:blank?)
      temp_user = User.find(user_id)
      participants.push(temp_user)
    end
    new_overtime['participants'] = participants
    if not self.update_attributes(new_overtime)
      return false
    end
        
    # create application flow for new participants
    for participant in self.participants
      if participant != self.applicant
        app_flow = OvertimeFlow.new
        app_flow.overtime = self
        app_flow.applicant = participant
        app_flow.set_viewer_state()
        app_flow.save() 
      end
    end
    
    return true
  end

  def revoke(user)
      self.state = OvertimeState.find_by_code('Revoke')
      self.save()
        
      flow = self.overtime_flow_by_user(user)
      flow.set_revoke_state()
      flow.save()

      flow = self.overtime_flow_by_user(user.superior)
      flow.delete()
        
      # application history
      self.write_history(user)
        
      return user.superior
  end
        
  def apply(user)
      self.state = OvertimeState.find_by_code('ReadyForDirectorApprove')
      self.save()
        
      current_flow = self.overtime_flow_by_user(user)
      current_flow.set_applicant_state()
      current_flow.save()

      next_flow = OvertimeFlow.new
      next_flow.overtime = self
      next_flow.applicant = user.superior
      next_flow.parent = current_flow
      next_flow.set_reviewer_state()
      next_flow.save()
        
      # application history
      self.write_history(user)
        
      return user.superior
  end

  def reject(user)
      self.state = ApplicationState.objects.get(code='Reject')
      self.save()
        
      flow = self.applicationflow_by_user(user)
      # change parent flow state
      parent_flow = flow.parent
      parent_flow.set_revoke_state()
      parent_flow.save()
      # delete current flow
      flow.delete()
        
      # application history
      self.write_history(user)
        
      return parent_flow.applicant
  end
        
  def approve(user)
      self.state = ApplicationState.objects.get(code='Approved')
      self.save()
        
      applicant_flow = self.applicationflow_by_user(self.applicant)
      applicant_flow.set_hidden_state()
      applicant_flow.save()
        
      current_flow = self.applicationflow_by_user(user)
      if user.userprofile.superior is None
          current_flow.delete()
      else
          current_flow.set_hidden_state()
          current_flow.save()

          next_flow = ApplicationFlow()
          next_flow.application = self
          next_flow.applicant = user.userprofile.superior
          next_flow.parent = current_flow
          next_flow.set_reviewer_state()
          next_flow.save()
      end
      # application history
      self.write_history(user)
  end

  def overtime_flow_by_user(user)
    return self.overtime_flows.where('applicant_id=?', user).first
  end 
  
  def write_history(user)
    history = OvertimeHistory.new
    history.overtime = self
    history.modified_by = user
    history.overtime_state = self.state
    history.save()
    self.modified_by = user
    self.save()
  end

end
