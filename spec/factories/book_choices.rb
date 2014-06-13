# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :book_choice do
    user_id 1
    round_id 1
    book_id 1
    state "MyString"
  end
end
