require 'spec_helper'

describe LineChoice do
  
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

    @round1 = @game.rounds.first

    @userA.choose_book(@round1, @@book1)

    @userB.draft_first_line(@round1, "this is the first line!")
    @userC.draft_first_line(@round1, "this is the first line!")
    @userD.draft_first_line(@round1, "this is the first line!")
    
    @first_lineB = @round1.all_first_lines.sample
    @userB.choose_first_line(@round1, @first_lineB)
    @first_lineC = @round1.all_first_lines.sample
    @userC.choose_first_line(@round1, @first_lineC)
    @first_lineD = @round1.all_first_lines.sample
    @userD.choose_first_line(@round1, @first_lineD)
    
    @round1 = Round.find(@round1.id)
    @game = @round1.game
    @true_line = @round1.book.first_lines.true_line[0]
    @false_lines = @round1.first_lines

  end

  describe "selected_true_line?" do
    it "returns true if the line choice was the true line and false otherwise." do
      
      @round1.line_choices.each {
        |lc|
        if lc.first_line_id == @true_line.id
          expect(lc.selected_true_line?).to eq true
        else
          expect(lc.selected_true_line?).to eq false
        end
      }
    end
  end

  describe "author_of_fake_line" do
    it "returns the games_user who wrote the fake line that was selected" do
      @round1.line_choices.each {
        |lc|
        if lc.first_line_id != @true_line.id
          expect(lc.author_of_fake_line.id).to eq lc.first_line.games_user.id
        end
      }
    end
  end

  describe ".score" do
    it "returns a hash with key of game users ids and a value of incremental score for that line_choice" do
      
      @round1.line_choices.each {
        |lc|
        expect(lc.score).to be_a Hash
        if lc.first_line_id == @true_line.id
          expect(lc.score[lc.games_user_id]).to eq 1
        end 
        if lc.first_line_id != @true_line.id
          expect(lc.score[lc.author_of_fake_line.id]).to eq 2
        end
      }

    end
  end




end