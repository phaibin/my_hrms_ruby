class Overtime < ActiveRecord::Base
    belongs_to :applicant, :class_name => 'User'
    belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by'
    belongs_to :state, :class_name => 'OvertimeState'
end
