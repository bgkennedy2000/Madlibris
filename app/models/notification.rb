class Notification < ActiveRecord::Base
  attr_accessible :checked, :subject, :user_id
end
