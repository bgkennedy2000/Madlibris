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
end