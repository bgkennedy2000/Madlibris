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
    it "returns true if no games_users are todo and false otherwise" do
    
      todos = @game.games_users.select { |games_user| games_user.try(:to_do?) }
      expect(todos).to eq []

    end
  end

  before(:all) do
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




  describe ".build_round_models" do

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

  describe ".new_round_needed?" do
    before(:each) do
      @userA = create(:user)
      @userB = create(:user)
      @userC = create(:user)
      @userD = create(:user)
      @userE = create(:user)
      @userF = create(:user)

      @game = @userA.new_game('multi-player')[0]
      @userA.invite_existing_user(@userB, @game)
      @userA.invite_existing_user(@userC, @game)
      @userA.invite_existing_user(@userD, @game)
      @userA.invite_existing_user(@userE, @game)

      @userB.accept_invitation(@game)
      @userC.accept_invitation(@game)
      @userD.accept_invitation(@game)
      @userE.accept_invitation(@game)

      @game = MadlibrisGame.find(@game.id) 
      @round1 = @game.rounds.first
      @userA.choose_book(@round1, @@book1)
      
      
      @userB.draft_first_line(@round1, "this is the first line!")
      @userC.draft_first_line(@round1, "this is the first line!")
      @userD.draft_first_line(@round1, "this is the first line!")
      @userE.draft_first_line(@round1, "this is the first line!")

      @first_lineB = @round1.all_first_lines.sample
      @userB.choose_first_line(@round1, @first_lineB)
      @first_lineC = @round1.all_first_lines.sample
      @userC.choose_first_line(@round1, @first_lineC)
      @first_lineD = @round1.all_first_lines.sample
      @userD.choose_first_line(@round1, @first_lineD)
      @round1 = Round.find(@round1.id)
      @first_lineE = @round1.all_first_lines.sample
      @userE.choose_first_line(@round1, @first_lineE)

      @round1 = Round.find(@round.id)
      @game = @round1.game
    end


    it "returns true if the number of rounds in the game is less than the number of games_users." do 
      expect(@game.rounds.length < @game.games_users.length).to eq true
      expect(@game.new_round_needed?).to eq true
    end

    it "returns true if any round in the game is not complete." do
      array = @game.rounds.map {
        |r|
        r.completed?
      }
      expect(array.include?(false)).to eq true
      expect(@game.new_round_needed?).to eq true
    end

    it "returns false if the number of rounds in the game equals the games_users in the game and all the rounds are complete." do

    end
  end

  describe ".current_score" do
    it "calculates the score of the game from completed rounds." do
      pending
    end
  end


end