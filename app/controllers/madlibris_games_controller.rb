class MadlibrisGamesController < ApplicationController
  load_and_authorize_resource

  def options_display
    @user = current_user || @user
    @current_games = current_user.ongoing_madlibris_games
    @pending_invites = current_user.invited_madlibris_games
    @notifications = current_user.notifications
    @game = MadlibrisGame.new
  end

  def create
    usernames = [ ]
    usernames << params[:username1] << params[:username2] << params[:username3] << params[:username4] << params[:username5] 
    @user = current_user || @user
    @game = MadlibrisGame.invite_usernames_to_game(usernames, @user)
    redirect_to(options_display_path)
  end

  def show
    @user = current_user
    @game = MadlibrisGame.find(params[:id])
    @books = Book.game_view(@game)
    @status = @game.status(@user)
  end

  def choose_book
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @book = Book.find(params[:book_id])
    @round = @game.latest_round
    @user.choose_book(@round, @book)
    options_display
  end

  def write_line

  end

  def accept_invite
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @user.accept_invitation(@game)
    redirect_to(write_line_path)
  end

  def reject_invite
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @user.reject_invitation(@game)
    redirect_to(options_display_path)
  end
end
