class OvertimeFlow < ActiveRecord::Base
  belongs_to :overtime
  belongs_to :applicant, :class_name => 'User'
  belongs_to :parent, :class_name => 'OvertimeFlow'
end
