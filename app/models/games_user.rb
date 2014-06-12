class GamesUser < ActiveRecord::Base
  attr_accessible :game_id, :invitation_status, :user_id, :user_role

  belongs_to :game
  belongs_to :madlibris_game
  belongs_to :user

  validates :game_id, presence: true
  validates :invitation_status, presence: true
  validates :user_id, presence: true
  validates :user_role, inclusion: { in: ["host", "invitee"] }

  after_initialize :defaults

  def defaults

  end

  include AASM

    aasm :column => 'invitation_status' do
      state :to_do, :initial => true
      state :pending
      state :accepted
      state :rejected

    event :invite do
      after do
        self.save
      end

      transitions :from => :to_do, :to => :pending
    end

    event :accept do
      before do
        self.game.game_active if self.game.may_game_active?
      end

      after do
        self.save
      end
      transitions :from => :pending, :to => :accepted
    end

    event :reject do
      before do
        self.game.game_active if self.game.may_game_active? 
      end
      after do
        self.save
      end
      transitions :from => :pending, :to => :rejected
    end
  end

  def send_invite
    if user.notifications.create(text: "#{user.username} has challenged you to a game")
      invite
    end
  end



end
