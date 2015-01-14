class Shift < ActiveRecord::Base
  #attributes: employee_id, role, start, length, finish, break_hours
  belongs_to :employee
  has_one :company, through: :employee
  validates_presence_of :employee_id, :role, :start, :length, :finish, :break_hours
end