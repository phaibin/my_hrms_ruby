class UserOvertime < ActiveRecord::Base
  belongs_to :user
  belongs_to :overtime
end
