class MadlibrisGame < Game
  # validate :has_multi_players?

  def progress_game
    if new_round_needed?
      build_round_models
    else
      complete
    end
  end

  def new_round_needed?
    not_enough_rounds? && any_incomplete_rounds?
  end

  def not_enough_rounds?
    rounds.length < games_users.length
  end

  def any_incomplete_rounds?
    incomplete_rounds = rounds.select { |r| r.completed? == false }
    incomplete_rounds.any?
  end
  
  def ready_to_play?
    if enough_players? && no_outstanding_invites? && no_invites_to_send?
      true
    else
      false
    end
  end

  def enough_players?
    players = games_users.select { |games_user| games_user.try(:accepted?) }
    if players
      players.length >= 3
    else
      false
    end
  end

  def no_outstanding_invites?
    games_users.select { |games_user| games_user.try(:pending?) } == [ ]
  end

  def no_invites_to_send?
    games_users.select { |games_user| games_user.try(:to_do?) } == [ ]
  end

  def build_round_models
    round = self.rounds.create
    book_choice = round.build_book_choice
    [round, book_choice]
  end

  def host
    games_users
  end




# need to be amended to accomodate game creation process, right now will blow it up
  def has_multi_players?
    if self.kind == 'multi-player'
      errors.add(:base, "A multi-player Madlibris Game must have at least three players.") unless self.users.length >= 3
    end
  end
end