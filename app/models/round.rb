class Round < ActiveRecord::Base
  attr_accessible :game_id, :state
  validates :game_id, presence: true
  
  belongs_to :game
  has_one :book_choice
  has_many :games_users, through: :game
  has_one :book, through: :book_choice
  has_many :line_choices
  has_many :first_lines_rounds
  has_many :first_lines, through: :first_lines_rounds, uniq: true


  include AASM

  aasm :column => 'state', :whiny_transitions => false do
    state :book_choosing, :initial => true
    state :first_line_writing
    state :line_choosing
    state :completed

    event :play do
      after do
        self.save
      end
      transitions :from => :book_choosing, :to => :first_line_writing
    end

    event :all_lines_complete do
      after do
        self.save
      end
      transitions :from => :first_line_writing, :to => :line_choosing, guard: :all_first_lines_written?
    end    


    event :complete do
      after do
        self.save
      end
      transitions :from => :line_choosing, :to => :completed
    end
  end

  def all_first_lines_written?
    all_complete_first_lines = all_first_lines.select{|line| line.written?}
    all_complete_first_lines.count == games_users.count
  end

  def all_first_lines
    false_first_lines = first_lines
    all_first_lines = false_first_lines << book.first_lines.true_line
  end

  def build_book_choice
    host_game_user = games_users.where_host[0]
     if choice = BookChoice.create(games_user_id: host_game_user.id, round_id: self.id)
        host_game_user.user.notifications.create(text: "To get the game started, please select a book")
     end
     choice
  end

  def create_first_line_and_associate_to_round(game_user, book)
    line = FirstLine.create(book_id: book.id, true_line: false, user_id: game_user.user_id, introductory_content_id: book.introductory_content.id, game_user_id: game_user.id)
    first_lines_rounds.create(first_line_id: line.id)
  end



end