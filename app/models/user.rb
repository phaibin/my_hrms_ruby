#!/usr/bin/env ruby
# -*- coding:utf-8 -*-

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
  has_many :user_overtimes
  has_many :overtimes, :through => :user_overtimes
  belongs_to :superior, :class_name => 'User'
  belongs_to :superior, :class_name => 'User'
  has_many :overtime_flows, :foreign_key => 'applicant_id'  
    
  def permissions
    user_permissions = []
    self.groups.each do |group|
      user_permissions.push *group.permissions
    end
    user_permissions
  end
  
  def can_add_overtime?
    add_overtime_permission = Permission.find_by_code('add_overtime')
    self.permissions.include?add_overtime_permission
  end
  
  def can_filter_overtime?
    add_overtime_permission = Permission.find_by_code('filter_overtime')
    self.permissions.include?add_overtime_permission
  end
  
  def is_hr?
    hr_group = Group.find_by_name('人事')
    self.groups.include?hr_group
  end
  
  def ==(another_user)
    self.id == another_user.id
  end
end
