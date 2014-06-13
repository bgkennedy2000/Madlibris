class Round < ActiveRecord::Base
  attr_accessible :game_id, :state
  validates :game_id, presence: true
  
  belongs_to :game
  has_one :book_choice
  has_many :games_users, through: :game
  has_one :book, through: :book_choice
  has_many :line_choices

  include AASM

  aasm :column => 'state' do
    state :book_choosing, :initial => true
    state :playing
    state :completed
  end

  def build_book_choice
    host_game_user = games_users.where_host[0]
    choice = BookChoice.create(games_user_id: host_game_user.id, round_id: self.id)
  end

end