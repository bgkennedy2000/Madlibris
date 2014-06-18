module MadlibrisGamesHelper

  def display_authors(book)
    names = book.authors.collect { |author| author.name }
    names.to_sentence
  end

  def display_game_info(user, game)
    link_to list_opponent_usernames(game, user), determine_game_url(game, user), class: "button expand #{link_class(user, game)}"
  end

  def list_opponent_usernames(game, user)
    games_users = (game.outstanding_invites << game.accepted_games_users).flatten
    user_names = games_users.collect { |gu| gu.user.username if gu.user.username != user.username }.compact
    opponents = user_names.join(" ") + " " + determine_message(game, user)
  end

  def opponents_array(game, user)
    games_users = (game.outstanding_invites << game.accepted_games_users).flatten
    user_names = games_users.collect { |gu| gu.user.username if gu.user.username != user.username }.compact
  end

  def determine_game_url(game, user)
    if game.needs_to_choose_book?(user)
      madlibris_game_path(game.id)
    elsif game.needs_to_write_line?(user)
      new_first_line_path(game.id)
    elsif game.needs_to_choose_line?(user)
      new_line_choice_path(game.id)
    else
      ""
    end
  end

  def determine_message(game, user)
    if game.needs_to_choose_book?(user) && game.rounds.try(:length) == 1
      "Choose Book to Start Game"
    elsif game.latest_round.try(:book_choosing?) && game.latest_round.try(:book_chooser) != user
      "Awaiting Book Choice"
    elsif game.needs_to_choose_book?(user)
      "Choose Book"
    elsif (game.latest_round.try(:first_line_writing?) && game.latest_round.try(:book_chooser) == user) || (game.latest_round.try(:first_line_writing?) && user.first_line_written?(game))
      "Awaiting Opponents' First Lines"
    elsif game.needs_to_write_line?(user)
      "Draft Line"
    elsif game.latest_round.try(:line_choosing?) && game.latest_round.try(:book_chooser) == user || (game.latest_round.try(:line_choosing?) && user.line_choosing?(game))
      "Awaiting Opponents Line Choices"
    elsif game.needs_to_choose_line?(user)
      "Pick Line"
    else
      "Awaiting Invite Responses"
    end
  end

  def link_class(user, game)
    classes = [ ]
    if list_opponent_usernames(game, user) == ""
    end
    if (game.game_host.id == user.id && game.proposing?) || game.playing?
      classes << "split" 
    end
    classes << "disable" unless activate_button?(game, user)
    classes.join(" ")
  end

  def activate_button?(game, user)
    if game.needs_to_choose_book?(user) || game.needs_to_write_line?(user) || game.needs_to_choose_line?(user)
      true
    else
      
    end
  end

end
