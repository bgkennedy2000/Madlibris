class GamesUser < ActiveRecord::Base
  attr_accessible :game_id, :invitation_status, :user_id, :user_role
  belongs_to :game
  belongs_to :user

  validates :game_id, presence: true
  validates :invitation_status, presence: true
  validates :user_id, presence: true
  validates :user_role, inclusion: { in: ["host", "invitee"] }

  include AASM

    aasm :column => 'invitation_status' do
      state :to_do, :initial => true
      state :pending
      state :accepted
      state :rejected

    event :invite do
      transitions :from => :to_do, :to => :pending, :guard => :invitation_sent?
    end

    event :accept do
      transitions :from => :pending, :to => :accepted
    end

    # event :sleep do
    #   transitions :from => :running, :to => :sleeping, :guard => :cleaning_needed?
    # end
  end

  def invitation_sent?

  end

end
