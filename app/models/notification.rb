class Notification < ActiveRecord::Base
  attr_accessible :checked, :text, :user_id

  validates :text, presence: true
  validates :user_id, presence: true
  
  after_initialize :defaults

  belongs_to :user

  def defaults
    self.checked = false
  end 

end
