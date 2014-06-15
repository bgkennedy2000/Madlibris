require 'spec_helper'

describe GamesUser do

  before(:each) do
    @user1 = create(:user)
    @game_games_users1 = @user1.new_game('single-player')
    @user2 = create(:user)
    @game_games_user2 = @user1.invite_existing_user(@user2, @game_games_users1[0])
  end

  describe ".send_invite" do

    it "creates a user notification" do
      expect(@user2.notifications.count).to eq 1
    end

    it "changes the status of a game user from to do to pending" do
      expect(@game_games_user2[1].pending?).to eq true
    end

    it "creates a notication with a checked equal to false" do
      expect(@user2.notifications[0].checked).to eq false
    end

  end

  describe ".get_line_choice(round)" do 
    before(:all) do 
      @userA = create(:user)
      @userB = create(:user)
      @userC = create(:user)
      @userD = create(:user)
      @userE = create(:user)
      @game = @userA.new_game("multi-player")[0]
      @userA.invite_existing_user(@userB, @game)
      @userA.invite_existing_user(@userC, @game)
      @userA.invite_existing_user(@userD, @game)
      @userB.accept_invitation(@game)
      @userC.accept_invitation(@game)
      @userD.accept_invitation(@game)
      @game = Game.find(@game.id)
      @round1 = @game.rounds.first
      @userA.choose_book(@round1, @@book1)
      @userB.draft_first_line(@round1, "this is the first line!")
      @userC.draft_first_line(@round1, "this is the first line!")
      @userD.draft_first_line(@round1, "this is the first line!")
      @game = Game.find(@game.id)
      @round1 = Round.find(@round1.id)
      @games_userB = @userB.get_accepted_games_user(@game)
    end
  
    it "returns a single line_choice for game user." do
 
      expect(@games_userB.get_line_choice(@round1)).to be_a LineChoice
    end

    it "returns a line choice that is in the round." do
      expect(@round1.line_choices.include?(@games_userB.get_line_choice(@round1))).to eq true
    end
  end
end
