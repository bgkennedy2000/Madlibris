class MadlibrisGame < Game
  validate :has_multi_players?


  def has_multi_players?
    if self.kind == 'multi-player'
      errors.add(:base, "A multi-player Madlibris Game must have at least three players.") unless self.users.length >= 3
    end
  end
end