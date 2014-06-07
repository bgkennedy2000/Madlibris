class Game < ActiveRecord::Base
  attr_accessible :state, :type, :kind
  has_and_belongs_to_many :users
  validates :state, inclusion: { in: ["proposed", "ongoing", "completed"]}
  validates :type, inclusion: { in: ["MadlibrisGame"] }
  validates :kind, inclusion: { in: ["single-player", "multi-player"] }
  validate :has_users?

  def has_users?
    errors.add(:base, "A game must have at least one user") if self.users == [ ]
  end



end
