require 'spec_helper'

describe Round do
  
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
    @game = Game.find(@game.id)
    @round1 = Round.find(@round1.id)
  end

  describe "all_first_lines_written?" do
    it "returns false if all the first lines are not written" do
      expect(@round1.line_choosing?).to eq false
      expect(@round1.all_first_lines_written?).to eq false
  end

    it "returns true if all the first lines are written" do
      @userD.draft_first_line(@round1, "this is the first line!")
      @round1 = Round.find(@round1.id)

      expect(@round1.line_choosing?).to eq true
      expect(@round1.all_first_lines_written?).to eq true
    end
  end

  describe "create_line_choice_and_associate_to_round(game_user)" do
    before(:each) do 
      @game = MadlibrisGame.find(@game.id)
      @round1 = Round.find(@round1.id)
      @userD_game_user = @userD.get_accepted_game_user(@game)
    end

    it "creates a line choice object for an invitee game users" do
      @round1.create_line_choice_and_associate_to_round(@userD_game_user)
      @userD_game_user = GamesUser.find(@userD_game_user.id)
      line_choices = @userD_game_user.line_choices.select{ |choice| choice.round_id == @round1.id }
      expect(line_choices.count).to eq 1
      expect(line_choices[0]).to be_a LineChoice
    end

    it "notifies invitee game users that they need to choose a line" do
      message = @round1.create_line_choice_and_associate_to_round(@userD_game_user)

      expect(message).to be_a Notification
    end
  end

  describe "build_line_choices" do 
    it "creates line choices for all the invittes" do
      @round1.build_line_choices
      @round1.line_choices.each { |line_choice|
        expect(line_choice.games_user).to_not eq nil
        expect(line_choice.games_user.user.host?(@round1.game)).to eq false
      }
    end
  end



end