class LineChoice < ActiveRecord::Base
  attr_accessible :first_line_id, :round_id, :state, :book_choice_id, :games_user_id
 
  validates :round_id, presence: true
  validates :games_user_id, presence: true
  validates :games_user_id, uniqueness: { scope: :round_id }

  belongs_to :first_line
  belongs_to :games_user
  has_one :user, through: :games_users
  belongs_to :round

# not able to get scopes working... 
  # scope :in_round, ->(round) { where round_id: round.id }
  # scope :with_games_user, ->(games_user) { where games_user_id: games_user.id }

  include AASM

  aasm :column => 'state', :whiny_transitions => false do
    state :pending, :initial => true
    state :completed

    event :complete do
      after do
        self.save
      end
      transitions :from => :pending, :to => :completed, guard: :has_first_line?
    end
  end

  def score
    score_hash = { }
    if selected_true_line?
      score_hash[games_user_id] = 1
    elsif selected_true_line? == false
      score_hash[author_of_fake_line.id] = 2
    else
      raise 'line_choice scoring error'
    end
    score_hash
  end

  def selected_true_line?
    first_line.true_line
  end

  def author_of_fake_line
    if first_line.true_line == false
      first_line.games_user
    end
  end

  def has_first_line?
    !!first_line
  end

  def game
    round.try(:game)
  end

  
  def book
    first_line.try(:book)
  end

end
