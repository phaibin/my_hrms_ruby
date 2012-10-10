class OvertimeHistory < ActiveRecord::Base
  belongs_to :overtime
  belongs_to :overtime_state
  belongs_to :modified_by, :class_name => 'User', :foreign_key => 'modified_by'
end
