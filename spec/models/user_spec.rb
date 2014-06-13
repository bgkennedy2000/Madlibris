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


    
end


