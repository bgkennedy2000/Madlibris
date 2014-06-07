class Book < ActiveRecord::Base
  attr_accessible :author, :image_url, :synopsis, :title
  
  validates :author, presence: true
  validates :synopsis, presence: true
  validates :title, presence: true
  
  has_many :rounds
  has_many :first_lines


end
