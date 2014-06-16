class GamesUser < ActiveRecord::Base
  attr_accessible :game_id, :invitation_status, :user_id, :user_role

  belongs_to :game
  belongs_to :madlibris_game
  belongs_to :user
  has_many :line_choices
  has_one :book_choice
  has_many :first_lines

  validates :game_id, presence: true
  validates :invitation_status, presence: true
  validates :user_id, presence: true
  validates :user_role, inclusion: { in: ["host", "invitee"] }

  scope :pendings, -> { where("invitation_status = ?", "pending") }
  scope :accepteds, -> { where("invitation_status = ?", "accepted") }
  scope :where_host, -> { where("user_role = ?", "host") }
  scope :where_invitee, -> { where("user_role = ?", "invitee") }


  after_initialize :defaults

  def defaults

  end

  include AASM

    aasm :column => 'invitation_status', :whiny_transitions => false do
      state :to_do, :initial => true
      state :pending
      state :accepted
      state :rejected
      state :kicked_out

    event :invite do
      after do
        self.save
      end

      transitions :from => :to_do, :to => :pending
    end

    event :accept do

      after do
        self.game.game_active if self.game.may_game_active?
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
  
    event :kick_out do
      after do
        self.save
      end
      transitions from: :pending, to: :kicked_out
      transitions from: :accepted, to: :kicked_out, guard: :enough_players?
    end
  end

  def my_move?(round)
    truth_array = [ ]
    truth_array << true if book_choice.try(:state) != "completed"
    truth_array << true if get_line_choice(round).try(:state) != "completed"
    truth_array << true if get_first_line(round).try(:state) != "written"
    truth_array.include?(true)
  end

  def get_first_line(round)
    line_choices.select { |lc| lc.round_id == round.id }.try(:first)
  end

  def get_line_choice(round)
    line_choices.select { |lc| lc.round_id == round.id }.try(:first)

    # scopes not working for some reason
    # LineChoice.in_round(round).with_games_user(self).first
  end

  def send_invite
    if user.notifications.create(text: "#{user.username} has challenged you to a game")
      invite
    end
  end

  def enough_players?
    game.games_users.accepteds.length > 3
  end


end
