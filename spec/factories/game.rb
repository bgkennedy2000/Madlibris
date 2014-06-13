# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :multi_player_game do
    type "MadlibrisGame"
    kind "multi-player"


    # 
    # userB = create(:user)
    # userC = create(:user)
    # userD = create(:user)
    # userE = create(:user)
    # game = userA.new_game("multi-player")[0]
    # game = userA.invite_existing_user(userB, game)[0]
    # game = userA.invite_existing_user(userC, game)[0]
    # game = userA.invite_existing_user(userD, game)[0]
    # game = userB.accept_invitation(game)
    # game = userC.accept_invitation(game)
    # game = userD.accept_invitation(game)
  end
end