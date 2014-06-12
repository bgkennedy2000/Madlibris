class Notification < ActiveRecord::Base
  attr_accessible :checked, :subject, :user_id
  validates :checked, presence: true
  validates :subject, presence: true
  validates :user_id, presence: true
  after_initialize :defaults

  belongs_to :user

  def defaults
    self.checked = false
  end 

end
