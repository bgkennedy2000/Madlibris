class MadlibrisGame < Game
  # validate :has_multi_players?


  
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




# need to be amended to accomodate game creation process, right now will blow it up
  def has_multi_players?
    if self.kind == 'multi-player'
      errors.add(:base, "A multi-player Madlibris Game must have at least three players.") unless self.users.length >= 3
    end
  end
end