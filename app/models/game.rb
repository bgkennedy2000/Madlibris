class Game < ActiveRecord::Base
  attr_accessible  :type, :kind, :state
  has_many :games_users
  has_many :users, through: :games_users
  has_many :rounds
  has_many :madlibris_plays
  # validates :state, inclusion: { in: ["proposed", "ongoing", "completed"]}
  validates :type, inclusion: { in: ["MadlibrisGame"] }
  validates :kind, inclusion: { in: ["single-player", "multi-player"] }
  # validate :has_users?
  # validate :has_one_player?

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
