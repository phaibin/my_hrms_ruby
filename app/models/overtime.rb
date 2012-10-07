class Overtime < ActiveRecord::Base
    belongs_to :applicant, :class_name => 'User'
end
