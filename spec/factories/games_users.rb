# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :games_user do
    game_id 1
    user_id 1
    invitation_status "MyString"
    user_role "MyString"
  end
end
