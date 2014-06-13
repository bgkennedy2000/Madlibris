require 'spec_helper'

describe MadlibrisGame do

  before(:each) do
    @user1 = create(:user)
    @user2 = create(:user)
    @user3 = create(:user)
    @user4 = create(:user)
    @user5 = create(:user)
    @user6 = create(:user)

    @game = @user1.new_game('multi-player')[0]
    @user1.invite_existing_user(@user2, @game)
    @user1.invite_existing_user(@user3, @game)
    @user1.invite_existing_user(@user4, @game)
    @user1.invite_existing_user(@user5, @game)
  end

  describe ".def ready_to_play?" do
    it "returns false if min of 3 people have not accepted an invitation" do
      
      expect(@game.ready_to_play?).to eq false
    end

    it "returns true if all outstanding invites have been accepted" do

      @user2.accept_invitation(@game)
      @user3.accept_invitation(@game)
      @user4.accept_invitation(@game)
      @user5.accept_invitation(@game)
      game = MadlibrisGame.find(@game.id)
      expect(game.playing?).to eq true
      expect(game.rounds.any?).to eq true 
    end

    it "returns false if one outstanding invitee is pending" do

      @user2.accept_invitation(@game)
      @user3.accept_invitation(@game)
      @user4.accept_invitation(@game)
      expect(@game.playing?).to eq false
    end

    it "returns true if all invites have been accepted or rejected" do

      @user2.accept_invitation(@game)
      @user3.accept_invitation(@game)
      @user4.accept_invitation(@game)
      @user5.reject_invitation(@game)
      game = MadlibrisGame.find(@game.id)
      expect(game.playing?).to eq true
      expect(game.rounds.any?).to eq true
    end
  end

  describe "enough_players?" do
    it "returns true if more than three accepted players attached to a game and false otherwise" do

      @user2.accept_invitation(@game)
      @user3.accept_invitation(@game)
      expect(@game.enough_players?).to eq true

      new_game = @user1.new_game('multi-player')[0]
      @user1.invite_existing_user(@user2, new_game )

      expect(new_game.enough_players?).to eq false
    end
  end

  describe "no_outstanding_invites?" do
    it "returns true no invites left are pending or to do and false otherwise" do
     
      @user2.accept_invitation(@game)
      @user3.reject_invitation(@game)
      

      expect(@game.no_outstanding_invites?).to eq false
      @user4.accept_invitation(@game)
      @user5.reject_invitation(@game)
      game = MadlibrisGame.find(@game.id)
      expect(game.no_outstanding_invites?).to eq true
    end

  end

  describe "no_invites_to_send?"    do
    it "returns true if no game_users are todo and false otherwise" do
    
      todos = @game.games_users.select { |games_user| games_user.try(:to_do?) }
      expect(todos).to eq []

    end
  end

  describe ".build_round_models" do

    before(:each) do
      @user1 = create(:user)
      @user2 = create(:user)
      @user3 = create(:user)
      @user4 = create(:user)
      @user5 = create(:user)
      @user6 = create(:user)

      @game = @user1.new_game('multi-player')[0]
      @user1.invite_existing_user(@user2, @game)
      @user1.invite_existing_user(@user3, @game)
      @user1.invite_existing_user(@user4, @game)
      @user1.invite_existing_user(@user5, @game)
      @user2.accept_invitation(@game)
      @user3.accept_invitation(@game)
      @user4.accept_invitation(@game)
      @game = MadlibrisGame.find(@game.id) 
    end

    it "returns a round and a first book choice" do 
      
      output = @game.build_round_models

      expect(output).to be_a Array
      expect(output[0]).to be_a Round
      expect(output[1]).to be_a BookChoice
    end

    it "has output that all ties together and is in the database." do

      output = @game.build_round_models
      round = Round.find(output[0].id)
      book_choice = BookChoice.find(output[1].id)
      game = Game.find(@game.id)

      expect(round.game.id).to eq game.id
      expect(book_choice.games_user.user_role).to eq "host"
      expect(round.book_choice).to eq book_choice
      expect(game.users.include?(book_choice.user)).to eq true

    end
  end

end