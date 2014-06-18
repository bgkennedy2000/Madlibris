class MadlibrisGame < Game
  # validate :has_multi_players?

  def choosing_book?
    truth_array = rounds.select { |r| r.book_choosing? }
    truth_array.include?(true)
  end
  
  def invited_users
    users = outstanding_invites.collect { |gu| gu.user }
  end

  def book_chooser?(user)
    chooser = latest_round.try(:book_chooser)
    user == chooser
  end

  def book_choice_pending?
    latest_round.book_choice.pending?
  end

  def needs_to_choose_book?(user)
    book_chooser?(user) && book_choice_pending? && playing?
  end

  def line_chooser?(user)
    line_choosers = latest_round.try(:line_choosers)
    if line_choosers
      line_choosers.include?(user)
    end
  end

  def line_writing?
    latest_round.first_line_writing?
  end

  def needs_to_write_line?(user)
    line_chooser?(user) && line_writing? && user.get_first_line(latest_round).try(:pending?)
  end

  def line_choosing?
    latest_round.line_choosing?
  end

  def needs_to_choose_line?(user)
    line_chooser?(user) && line_choosing? && user.get_line_choice(latest_round).try(:pending?)
  end

  def self.invite_usernames_to_game(usernames_array, game_host)
    new_game = game_host.new_game("multi-player")[0]
    confirmed_invites = [ ]
    usernames_array.each { |username|
      if user = User.find_by_username(username)
        game_host.invite_existing_user(user, new_game)
        confirmed_invites << username
      end
    }
    game_host.notifications.create(text: "#{confirmed_invites.join(", ")} were successfully invited to the game}")
    new_game
  end

  def game_host
    games_users.collect { |gu| gu.user if gu.user_role == "host" }.compact[0]
  end

  def progress_game
    if new_round_needed?
      build_round_models
    else
      complete
    end
  end

  def new_round_needed?
    not_enough_rounds? || any_incomplete_rounds?
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

  def accepted_games_users
    games_users.select { |games_user| games_user.try(:accepted?) }
  end

  def enough_players?
    players = accepted_games_users
    if players
      players.length >= 3
    else
      false
    end
  end

  def latest_round
    rounds.sort_by { |r| r.created_at }.last
  end

  def no_outstanding_invites?
    games_users.select { |games_user| games_user.try(:pending?) } == [ ]
  end

  def outstanding_invites
    games_users.select { |games_user| games_user.try(:pending?) }
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

  def current_score
    game_score_hash = zero_points_hash
    if completed_rounds.any?
      completed_rounds.each { |round|
        game_score_hash = add_round_to_current_score(game_score_hash, round.current_score)
      }
    end
    game_score_hash
  end

  def add_round_to_current_score(round_hash, current_score_hash)
    game_user_ids = round_hash.keys.sort
    raise "error compiling score" unless game_user_ids == current_score_hash.keys.sort
      game_user_ids.each { |id|
        current_score_hash[id] = current_score_hash[id] + round_hash[id]
      }
    current_score_hash
  end

  def zero_points_hash
    hash = { }
    games_users.each {
        |gu|
        hash[gu.id] = 0
    }
    hash
  end

  def completed_rounds
    rounds.select { |round| round.completed?}
  end



# need to be amended to accomodate game creation process, right now will blow it up
  def has_multi_players?
    if self.kind == 'multi-player'
      errors.add(:base, "A multi-player Madlibris Game must have at least three players.") unless self.users.length >= 3
    end
  end
end