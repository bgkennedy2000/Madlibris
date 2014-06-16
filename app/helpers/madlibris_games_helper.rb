module MadlibrisGamesHelper

  def display_authors(book)
    names = book.authors.collect { |author| author.name }
    names.to_sentence
  end

  def display_game_info(user, game) 
    link_to list_opponent_usernames(game), madlibris_game_path(game.id), class: "button expand", id: "#{link_class(user, game)}"
  end


  def list_opponent_usernames(game)
    user_names = game.games_users.collect { |gu| gu.user.username }
    opponents = user_names.join(", ")
  end

  def link_class(user, game)
    if user.my_move?(game)
      "my_move"
    else
      "their_move"
    end
  end

end
