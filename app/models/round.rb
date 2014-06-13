class Round < ActiveRecord::Base
  attr_accessible :game_id, :state
  validates :game_id, presence: true
  
  belongs_to :game
  has_one :book_choice
  has_many :games_users, through: :game
  has_one :book, through: :book_choice
  has_many :line_choices
  has_many :first_lines_rounds
  has_many :first_lines, through: :first_lines_rounds


  include AASM

  aasm :column => 'state' do
    state :book_choosing, :initial => true
    state :playing
    state :completed
  end

  def build_book_choice
    host_game_user = games_users.where_host[0]
     if choice = BookChoice.create(games_user_id: host_game_user.id, round_id: self.id)
        host_game_user.user.notifications.create(text: "To get the game started, please select a book")
     end
     choice
  end

  def create_first_line_and_associate_to_round(game_user, book)
    line = FirstLine.create(book_id: book.id, true_line: false, user_id: game_user.user_id)
    first_lines_rounds.create(first_line_id: line.id)
  end


end