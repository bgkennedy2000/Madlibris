class LineChoice < ActiveRecord::Base
  attr_accessible :first_line_id, :round_id, :state, :book_choice_id
 
  validates :round_id, presence: true
  validates :games_user_id, presence: true

  belongs_to :first_line
  belongs_to :games_user
  has_one :user, through: :games_users
  belongs_to :round
  
  def game
    round.try(:game)
  end

  
  def book
    first_line.try(:book)
  end

end
