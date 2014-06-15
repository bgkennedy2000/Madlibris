require 'spec_helper'

describe Round do
  
  before(:each) do
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

  describe "create_line_choice_and_associate_to_round(games_user)" do
    before(:each) do 
      @game = MadlibrisGame.find(@game.id)
      @round1 = Round.find(@round1.id)
      @userD_games_user = @userD.get_accepted_games_user(@game)
    end

    it "creates a line choice object" do
      @round1.create_line_choice_and_associate_to_round(@userD_games_user)
      @userD_games_user = GamesUser.find(@userD_games_user.id)
      line_choices = @userD_games_user.line_choices.select{ |choice| choice.round_id == @round1.id }
      expect(line_choices.count).to eq 1
      expect(line_choices[0]).to be_a LineChoice
    end

    it "notifies the game users that they need to choose a line" do
      message = @round1.create_line_choice_and_associate_to_round(@userD_games_user)

      expect(message).to be_a Notification
    end
  end

  describe "build_line_choices" do 
    it "creates line choices for all the users except the user that made the book choice" do
      @round1.build_line_choices
      @round1.line_choices.each { |line_choice|
        expect(line_choice.games_user).to_not eq nil
        expect(line_choice.games_user.id == @round1.book_choice.games_user_id).to eq false
      }
    end
  end

  describe ".all_line_choices_made?" do
    before(:each) do
      @userD.draft_first_line(@round1, "this is the first line!")
      @first_lineB = @round1.all_first_lines.sample
      @userB.choose_first_line(@round1, @first_lineB)
      @first_lineC = @round1.all_first_lines.sample
      @userC.choose_first_line(@round1, @first_lineC)
      @round1 = Round.find(@round1.id)
    end

    it "returns false if all the line_choices in that round have not been made." do
      expect(@round1.all_line_choices_made?).to eq false
    end

    it "returns true if all the line_choices in that round have been made." do
      @first_lineD = @round1.all_first_lines.sample
      @userD.choose_first_line(@round1, @first_lineD)

      @round1 = Round.find(@round1.id)
      expect(@round1.all_line_choices_made?).to eq true
    end

  end

  describe "get_games_user_that_made_book_choice" do
    it "returns the games_user that made the book choice in that round" do
      @round1 = Round.find(@round1.id)
      @userA = User.find(@userA.id)
      expect(@userA.get_accepted_games_user(@game).id).to eq  @round1.get_games_user_that_made_book_choice.id      
    end
  end

  describe ".current score" do
    before(:each) do
      @userD.draft_first_line(@round1, "this is the first line!")
      @first_lineB = @round1.all_first_lines.sample
      @userB.choose_first_line(@round1, @first_lineB)
      @first_lineC = @round1.all_first_lines.sample
      @userC.choose_first_line(@round1, @first_lineC)
      @first_lineD = @round1.all_first_lines.sample
    end

    it "returns nil if round is not complete." do
      expect(@round1.completed?).to eq false
      expect(@round1.current_score).to eq nil
    
    end

    it "returns a hash containg all the game_users ids as keys, and their line_choice score as values if round is complete" do
      @userD.choose_first_line(@round1, @first_lineD)
      @round1 = Round.find(@round1.id)

      expect(@round1.completed?).to eq true
      expect(@round1.current_score).to be_a Hash
      expect(@round1.current_score.length).to eq @round1.games_users.length
      expect(@round1.current_score[@round1.games_users.sample.id]).to be_a Integer
    end

  end

end