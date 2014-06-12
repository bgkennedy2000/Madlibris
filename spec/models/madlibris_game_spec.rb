require 'spec_helper'

describe MadlibrisGame do

  before(:each) do
    @user1 = create(:user)
    @user2 = create(:user)
    @user3 = create(:user)
    @user4 = create(:user)

    @invalid_game = @user1.new_game('multi-player')
    @user1.invite_existing_user(@user2, @invalid_game)
    @user1.invite_existing_user(@user3, @invalid_game)
  end

  describe ".def ready_to_play?" do
    it "returns false if min of 3 people have not accepted an invitation" do
      
      expect(@invalid_game.ready_to_play?).to eq false
    end
  end
end