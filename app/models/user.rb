class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
  
    has_many :overtimes, :foreign_key => 'applicant_id'  
    has_many :user_groups
    has_many :groups, :through => :user_groups
    belongs_to :superior, :class_name => 'User'
end
