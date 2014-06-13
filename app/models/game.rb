class Game < ActiveRecord::Base
  attr_accessible  :type, :kind, :state
  has_many :games_users
  has_many :users, through: :games_users
  has_many :rounds
  # validates :state, inclusion: { in: ["proposed", "ongoing", "completed"]}
  validates :type, inclusion: { in: ["MadlibrisGame"] }
  validates :kind, inclusion: { in: ["single-player", "multi-player"] }
  # validate :has_users?
  # validate :has_one_player?

  include AASM

  aasm :column => 'state' do
    state :proposing, :initial => true
    state :playing
    state :completed

    event :game_active do
      after do
        self.build_round_models
        self.save
      end
      transitions :from => :proposing, :to => :playing
    end

  end


# needs to accomodate game creation process, right now blows it up due to game state
  def has_one_player?
    if self.kind == 'single-player'
      errors.add(:base, "A single-player game must have only one player.") unless self.users.length == 1
    end
  end

# needs to accomodate game creation process, right now blows it up due to game state
  def has_users?
    errors.add(:base, "A game must have at least one user") if self.users == [ ]
  end


  

end
