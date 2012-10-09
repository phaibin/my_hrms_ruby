class Overtime < ActiveRecord::Base
    belongs_to :applicant, :class_name => 'User'
    belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by'
    belongs_to :state, :class_name => 'OvertimeState'
    has_many :user_overtimes
    has_many :participants, :through => :user_overtimes, :source => :user
      
    validates_presence_of :subject, :on => :create, :message => "can't be blank"
end
