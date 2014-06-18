class MadlibrisGamesController < ApplicationController
  load_and_authorize_resource

  def options_display
    @user = current_user || @user
    @current_games = current_user.ongoing_madlibris_games
    @pending_invites = current_user.invited_madlibris_games
    @notifications = current_user.notifications
    @game = MadlibrisGame.new
    render action: "options_display"
  end

  def create
    usernames = [ ]
    usernames << params[:username1] << params[:username2] << params[:username3] << params[:username4] << params[:username5] 
    @user = current_user || @user
    @game = MadlibrisGame.invite_usernames_to_game(usernames, @user)
    @books = Book.game_view(@game, @user)
    redirect_to(options_display_path)
  end

  def show
    @user = current_user
    @game = MadlibrisGame.find(params[:id])
    @books = Book.game_view(@game, @user)
    # @status = @game.status(@user)
  end

  def choose_book
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @book = Book.find(params[:book_id])
    @round = @game.latest_round
    @user.choose_book(@round, @book)
    redirect_to(options_display_path)
  end

  def new_line
    @user = current_user
    @game = MadlibrisGame.find(params[:id])
    @books = Book.game_view(@game, @user)
    render action: "new_line"
  end

  def write_line
    @user = current_user
    @round = Round.find(params[:round_id])
    @text = params[:text]
    @user.draft_first_line(@round, @text)
    redirect_to(options_display_path)
  end

  def new_line_choice
    @user = current_user
    @game = MadlibrisGame.find(params[:id])
    @round = @game.latest_round
    @books = Book.game_view(@game, @user)
  end

  def choose_line
    @user = current_user
    @round = Round.find(params[:round_id])
    @first_line = FirstLine.find(params[:first_line_id])
    @user.choose_first_line(@round, @first_line)
    redirect_to(options_display_path)
  end

  def accept_invite
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @user.accept_invitation(@game)
    redirect_to(options_display_path)
  end

  def reject_invite
    @user = current_user
    @game = MadlibrisGame.find(params[:game_id])
    @user.reject_invitation(@game)
    redirect_to(options_display_path)
  end

  def uninvite
    @user = current_user
    @uninvited_user = User.find_by_username(params[:username])
    @game = MadlibrisGame.find(params[:game_id])
    @result = @user.uninvite_from_game(@uninvited_user, @game)

    respond_to do |format|
      format.json { render :json => { user: @uninvited_user.username, game: @game.id, result: @result } }
    end
  end

  def send_invite
    @user = current_user
    if @invited_user = User.find_by_username(params[:username])
      @game = MadlibrisGame.find(params[:game_id])
      @game = @user.invite_existing_user(@invited_user, @game)[0]
      @result = true
    else
      @result = false
    end
    respond_to do |format|
      format.json { render :json => { game: @game.id, username: @invited_user.username, result: @result } }
    end
  end

end
