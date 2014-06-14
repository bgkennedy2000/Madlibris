require 'spec_helper'

describe User do
  before(:each) do
    @user = create(:user)
    @userA = create(:user)
    @userB = create(:user)
    @userC = create(:user)
    @userD = create(:user)
    @userE = create(:user)
    @game = @userA.new_game("multi-player")[0]
    @game = @userA.invite_existing_user(@userB, @game)[0]
    @game = @userA.invite_existing_user(@userC, @game)[0]
    @game = @userA.invite_existing_user(@userD, @game)[0]
    @game2 = @userE.new_game("multi-player")[0]
    @game2 = @userE.invite_existing_user(@userD, @game2)[0]

  end
  
  describe ".new_game" do

  before(:each) do
    @game_games_user = @user.new_game("single-player")
  end

    it "returns an array with a new game and a new game_user" do


      expect(@game_games_user).to be_a Array
      expect(@game_games_user[0]).to be_a Game
      expect(@game_games_user[1]).to be_a GamesUser
    end

    it "has output that all ties together" do
      
      game = @game_games_user[0]
      games_user = @game_games_user[1]

      expect(game.users.include?(@user)).to eq true
      expect(game.games_users.include?(games_user)).to eq true
      expect(games_user.game).to eq game
      expect(games_user.user).to eq @user
      expect(@user.games.include?(game)).to eq true
    end
  end

  describe "invite_existing_user(user, game)" do

    before(:each) do
      @game_games_user = @userA.invite_existing_user(@userB, @game )
    end

    it "returns an array with a new game and a new game_user" do

      expect(@game_games_user).to be_a Array
      expect(@game_games_user[0]).to be_a Game
      expect(@game_games_user[1]).to be_a GamesUser

    end

    it "has output that all ties together" do
      
      game = @game_games_user[0]
      games_user = @game_games_user[1]

      expect(game.users.include?(@userA) && game.users.include?(@userB)).to eq true
      expect(game.games_users.include?(games_user)).to eq true
      expect(games_user.game).to eq game
      expect(games_user.user).to eq @userB
      expect(@userB.games.include?(game)).to eq true
    end

    it "results in the user receiving a notification to the user" do
      expect(@userB.notifications.count).to eq 2
      expect(@userD.notifications.count).to eq 2
    end

  end

  describe "pending_invites" do
    it "returns all the pending games_users" do
      expect(@userB.pending_invites.count).to eq 1
      expect(@userD.pending_invites.count).to eq 2
    end
  end

  describe ".accept_invitation(game)" do
    it "makes a game_user accept an invite and persists it in the database" do
      
      @userF = create(:user)
      @game_game_user1 = @userE.invite_existing_user(@userF, @game2)

      game_user = @userF.accept_invitation(@game_game_user1[0])

      expect(game_user.accepted?).to eq true

      @userG = User.find(@userF.id)
      updated_game_user = @userG.games_users.select { |gu| gu.game_id == @game_game_user1[0].id }[0]
      expect(updated_game_user.accepted?).to eq true
    end
  end

  describe "reject_invitation" do
    it "makes a game_user reject an invite" do

      @userF = create(:user)
      @game_game_user1 = @userE.invite_existing_user(@userF, @game2)

      game_user = @userF.reject_invitation(@game_game_user1[0])

      expect(game_user.rejected?).to eq true

    end
  end    

  describe ".uninvite_from_game" do
    it "if you are a host, allows you to uninvite a pending user from a game" do
      
      game_user = @userA.uninvite_from_game(@userD, @game)
      expect(game_user.kicked_out?).to eq true

      game_user = @userB.uninvite_from_game(@userC, @game)
      expect(game_user.kicked_out?).to eq false
    
    end

    it "allows the host to kick out players from the game if there are enought players after the kickout" do
      @userB.accept_invitation(@game)      
      @userC.accept_invitation(@game)  
      @userD.accept_invitation(@game) 
      game = MadlibrisGame.find(@game.id)

      game_user = @userA.uninvite_from_game(@userD, game)
      expect(game_user.user.id).to eq @userD.id
      expect(game_user.kicked_out?).to eq true

      game = MadlibrisGame.find(@game.id)
      game_user = @userA.uninvite_from_game(@userC, game)
      expect(game_user.user.id).to eq @userC.id
      expect(game_user.kicked_out?).to eq false


    end
  end

  describe ".choose_book(round, book)" do

    before(:each) do
      @userA = create(:user)
      @userB = create(:user)
      @userC = create(:user)
      @userD = create(:user)
      @userE = create(:user)
      @game = @userA.new_game("multi-player")[0]
      @userA.invite_existing_user(@userB, @game)[0]
      @userA.invite_existing_user(@userC, @game)[0]
      @userA.invite_existing_user(@userD, @game)[0]
      @userB.accept_invitation(@game)      
      @userC.accept_invitation(@game)  
      @userD.accept_invitation(@game) 
      @game = MadlibrisGame.find(@game.id)
      @round = @game.rounds.first
      

    end

    it "sets the book in the book_choice and is accessible by the round" do
      @userA.choose_book(@round, @@book1)
      
      expect(@@book1.id).to be_a Integer
      expect(@round.book_choice).to be_a BookChoice
      expect(@round.book_choice.book.id).to be @@book1.id
        
    end

    it "changes the state of the round to playing." do
      @userA.choose_book(@round, @@book1)
      @round = Round.find(@round.id)

      expect(@round.first_line_writing?).to eq true
    end

    it "creates new first_line for all other members of the game and sends them each a notification to read the book and draft a fake first sentence of that book" do
      @userA.choose_book(@round, @@book1)


      expect(@round.first_lines.length).to eq @round.games_users.length - 1
      invitee_games_users = @round.games_users.select { |gu| gu.user_role == "invitee" }
      truth_array = invitee_games_users.map { |gu| gu.user.first_lines.any? }
      expect(truth_array.include?(false)).to eq false
    end

    it "can only be set by the host" do
      @userB.choose_book(@round, @@book1)
      @round = Round.find(@round.id)

      expect(@round.first_line_writing?).to eq false
      expect(@round.first_lines).to eq []
    end

    it "returns an array of notifications to the users" do
      
      messages = @userA.choose_book(@round, @@book1)

      expect(messages.class).to eq Array
      messages.each { |message|
        expect(message.class).to eq Notification
        expect(message.user_id).not_to be nil
      }
    end

    it "sets the introductory content of the new first lines to the introductory content of the true first line" do


      @userA.choose_book(@round, @@book1)
      round = Round.find(@round.id)

      round.first_lines.each {
        |first_line|
        expect(first_line.introductory_content.id).to eq @@book1.introductory_content.id
      }
    end

    it "sets the book_choice status to completed" do
      @userA.choose_book(@round, @@book1)
      round = Round.find(@round.id)

      expect(round.book_choice.completed?).to eq true
    end
  end

  describe "def host?(game)" do
    it "returns true if the user is the host of the game and false if not the host" do
      userA = create(:user)
      game = userA.new_game("multi-player")[0]
      userB = create(:user)

      expect(userA.host?(game)).to eq true
      expect(userB.host?(game)).to eq false
    end
  end

  describe "def make_book_choice(round, book)" do 
    it "saves to the database a new book choice for that round, with that book" do

      userA = create(:user)
      game = userA.new_game("multi-player")[0]
      game.build_round_models
      game = MadlibrisGame.find(game.id)

      userA.make_book_choice(game.rounds.first, @@book1)
      round = Round.find(game.rounds.first.id)

      expect(round.book_choice.book.id).to eq @@book1.id

    end
  end

  describe ".draft_first_line(round, text)" do
    before(:each) do
      @userB.accept_invitation(@game)
      @userC.accept_invitation(@game)
      @userD.accept_invitation(@game)
      @userA.choose_book(@game.rounds.first, @@book1) 
      @game = Game.find(@game.id)
      @round = @game.rounds.first
      @userB.draft_first_line(@round, "this is the first line!")
    end

    it "add the first line text to the first_line for that round" do
      game_user = @userB.get_accepted_game_user(@game)
      first_line = FirstLinesRound.find_by_round_id(@round.id).first_line
      expect(first_line.text).to eq "this is the first line!"
    end


    it "doesn't complete the round if all first lines have not been written" do
      round = Round.find(@round.id)
      expect(round.line_choosing?).to eq false
    end

    it "completes the round if all first lines have been written" do
      @userC.draft_first_line(@round, "this is the first line!")
      @userD.draft_first_line(@round, "this is the first line!")
      round = Round.find(@round.id)
      
      expect(round.line_choosing?).to eq true
    end
  end


  describe ".choose_first_line(round)" do
    
  end


    
end


