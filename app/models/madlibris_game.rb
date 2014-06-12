class MadlibrisGame < Game
  # validate :has_multi_players?
  include AASM

  aasm :column => 'state' do
    state :proposing, :initial => true
    state :playing
    state :completed

    event :game_active do
      transitions :from => :proposing, :to => :playing, guard: :ready_to_play?
    end

    # event :clean do
    #   transitions :from => :running, :to => :cleaning
    # end

    # event :sleep do
    #   transitions :from => :running, :to => :sleeping, :guard => :cleaning_needed?
    # end
  end

  def ready_to_play?
    if enough_players? && no_oustanding_invites?
      true
    else
      false
    end
  end

  def enough_players?
    games_users.select { |games_user| games_user.try(:accepted?) }.length >= 3
  end

  def no_outstanding_invites?
    games_users.select { |games_user| games_user.try(:pending?) || games_user.try(:to_do?) } == [ ]
  end




# need to be amended to accomodate game creation process, right now will blow it up
  def has_multi_players?
    if self.kind == 'multi-player'
      errors.add(:base, "A multi-player Madlibris Game must have at least three players.") unless self.users.length >= 3
    end
  end
end