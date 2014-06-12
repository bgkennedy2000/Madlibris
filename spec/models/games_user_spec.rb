require 'spec_helper'

describe GamesUser do

  before(:each) do
    @user1 = create(:user)
    @game_game_users1 = @user1.new_game('single-player')
    @user2 = create(:user)
    @game_game_user2 = @user1.invite_existing_user(@user2, @game_game_users1[0])
  end

  describe ".send_invite" do

    it "creates a user notification" do
      expect(@user2.notifications.count).to eq 1
    end

    it "changes the status of a game user from to do to pending" do
      expect(@game_game_user2[1].pending?).to eq true
    end

    it "creates a notication with a checked equal to false" do
      expect(@user2.notifications[0].checked).to eq false
    end

  end

end
