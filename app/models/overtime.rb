class Overtime < ActiveRecord::Base
  belongs_to :applicant, :class_name => 'User'
  belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by'
  belongs_to :state, :class_name => 'OvertimeState'
  has_many :user_overtimes
  has_many :participants, :through => :user_overtimes, :source => :user
      
  validates_presence_of :subject, :on => :create, :message => "can't be blank"
    
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
    
  def write_history(user)
    history = OvertimeHistory.new
    history.overtime = self
    history.modified_by = user
    history.overtime_state = self.state
    history.save()
    self.modified_by = user
    self.save()
  end
  
  def participants_string
      return self.participants.collect{|x| x.chinese_name}.compact.join(', ')
  end
end
