class Game < ActiveRecord::Base
  attr_accessible  :type, :kind, :state
  has_and_belongs_to_many :users
  # validates :state, inclusion: { in: ["proposed", "ongoing", "completed"]}
  validates :type, inclusion: { in: ["MadlibrisGame"] }
  validates :kind, inclusion: { in: ["single-player", "multi-player"] }
  validate :has_users?
  include AASM

  def has_users?
    errors.add(:base, "A game must have at least one user") if self.users == [ ]
  end

  aasm :column => 'state' do
    state :proposing, :initial => true
    state :playing
    state :completing

    # event :run do
    #   transitions :from => :sleeping, :to => :running
    # end

    # event :clean do
    #   transitions :from => :running, :to => :cleaning
    # end

    # event :sleep do
    #   transitions :from => :running, :to => :sleeping, :guard => :cleaning_needed?
    # end
  end



end
