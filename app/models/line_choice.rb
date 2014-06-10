class LineChoice < ActiveRecord::Base
  attr_accessible :first_line_id, :round_id, :user_id
 
  validates :first_line_id, presence: true
  validates :round_id, presence: true
  validates :user_id, presence: true

  belongs_to :first_line
  belongs_to :user
  belongs_to :round
  
  def game
    round.try(:game)
  end

  
  def book
    first_line.try(:book)
  end

end
