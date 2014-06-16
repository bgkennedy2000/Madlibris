class MadlibrisGamesController < ApplicationController


  def options_display
    @user = current_user || @user
    @games = current_user.ongoing_madlibris_games
    @notifications = current_user.notifications
    @game = MadlibrisGame.new
  end

  def create
    usernames = [ ]
    usernames << params[:username1] << params[:username2] << params[:username3] << params[:username4] << params[:username5] 
    @user = current_user
    @game = MadlibrisGame.invite_usernames_to_game(usernames, @user)
    redirect_to(root_path)
  end

  def show
    @user = current_user
    @game = MadlibrisGame.find(params[:id])
    @books = Book.game_view(@game)
  end


end
