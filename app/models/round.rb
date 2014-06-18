class Round < ActiveRecord::Base
  attr_accessible :game_id, :state
  
  validates :game_id, presence: true
  # validate :previous_round_complete?

  belongs_to :game
  has_one :book_choice
  has_many :games_users, through: :game
  has_one :book, through: :book_choice
  has_many :line_choices
  has_many :first_lines_rounds, dependent: :destroy
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
        build_line_choices
        self.save
      end
      transitions :from => :first_line_writing, :to => :line_choosing, guard: :all_first_lines_written?
    end    

    event :complete do
      after do
        self.save
        self.game.progress_game
      end
      transitions :from => :line_choosing, :to => :completed, guard: :all_line_choices_made?
    end
  end


  def previous_round_complete?
    if game.rounds.length > 1
      previous_rounds = game.rounds.sort_by { |round| round.created_at }
      errors.add(:base, "round cannot save until previous round completed.") unless previous_rounds.select { |round| round.completed? } == previous_rounds 
    end
  end

  def all_line_choices_made?
    truth_array = line_choices.collect { |lc| lc.completed? }
    !truth_array.include?(false)
  end

  def all_first_lines_written?
    all_complete_first_lines = all_first_lines.select{|line| line.written?}
    all_complete_first_lines.count == games_users.select{ |gu| gu.accepted? }.count
  end

  def all_first_lines
    false_first_lines = first_lines
    all_first_lines = false_first_lines << book.first_lines.true_line
  end

  def build_book_choice
    book_chooser = determine_book_chooser
     if choice = BookChoice.create(games_user_id: book_chooser.id, round_id: self.id)
        book_chooser.user.notifications.create(text: "To get the game started, please select a book")
        
     end
     choice
  end

  def get_line_choosers_games_users
    users = line_choosers
    users.collect { |user| user.get_accepted_games_user(game) }.compact
  end

  def determine_book_chooser
    rounds = game.rounds << self
    if rounds.length < 2
      games_users.where_host[0]
    else
      previous_round = rounds.sort_by { |r| r.created_at }[-2]
      previous_line_choices = previous_round.line_choices.sort_by {|lc| lc.updated_at }
      previous_line_choices.last.games_user
    end
  end

  def create_first_line_and_associate_to_round(games_user, book)
    line = FirstLine.create(book_id: book.id, true_line: false, user_id: games_user.user.try(:id), introductory_content_id: book.introductory_content.id, games_user_id: games_user.id)
    first_lines_rounds.create(first_line_id: line.id)
  end

  def create_line_choice_and_associate_to_round(games_user)
    if line_choices.create(games_user_id: games_user.id)
      games_user.user.notifications.create(text: "Its time to choose which line you think is the real first line of the book.")
    end
  end

  def build_line_choices
    book_chooser = get_games_user_that_made_book_choice
    choosing_games_users = games_users.select{ |gu| gu.accepted? }
    choosing_games_users.each {
      |games_user|
      unless games_user.id == book_chooser.id
        create_line_choice_and_associate_to_round(games_user)
      end
    }
  end

  def get_games_user_that_made_book_choice
    book_choice.games_user
  end

  def book_chooser
    book_choice.games_user.user
  end

  def line_choosers
    games_users_array = games_users.select { |gu| gu.user.id != book_chooser.id }
    games_users_array = games_users_array.select { |gu| gu.accepted? }
    games_users_array.collect{ |gu| gu.user }
  end

  def current_score
    if completed? == false
      { }
    else
      score_hash = { }
      games_users.each {
        |gu|
        score_hash[gu.id] = 0
      }
      line_choices.each { 
        |lc|
        score_hash[lc.score.keys.first] = score_hash[lc.score.keys.first] + lc.score[lc.score.keys.first]
      }
      if nobody_chose_correct_first_line?
        score_hash[book_choice.games_user_id] = score_hash[book_choice.games_user_id] + 2 
      end
      score_hash
    end
  end

  def nobody_chose_correct_first_line?
    truth_array = line_choices.collect {
      |lc|
      lc.selected_true_line?
    }
    !truth_array.include?(true)
  end


end