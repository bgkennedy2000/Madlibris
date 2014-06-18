module MadlibrisGamesHelper

  def display_authors(book)
    names = book.authors.collect { |author| author.name }
    names.to_sentence
  end

  def display_game_info(user, game)
    link_to list_opponent_usernames(game, user), determine_game_url(game, user), class: "button split #{link_class(user, game)}"
  end

  def list_opponent_usernames(game, user)
    user_names = game.games_users.collect { |gu| gu.user.username if gu.user.username != user.username }.compact
    opponents = user_names.join(", ")
  end

  def determine_game_url(game, user)
    if game.needs_to_choose_book?(user)
      madlibris_game_path(game.id)
    elsif game.needs_to_write_line?(user)
      new_first_line_path(game.id)
    elsif game.needs_to_choose_line?(user)
      new_line_choice_path(game.id)
    else
      
    end
  end

  def link_class(user, game)
    classes = [ ]
    if list_opponent_usernames(game, user) == ""
      classes << "hide-button"
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
