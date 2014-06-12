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

  end

  describe "pending_invites" do
    it "returns all the pending games_users" do
      expect(@userD.pending_invites).to eq @userD.games_users
    end
  end

    


    
end


