# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :notification do
    subject "MyString"
    user_id 1
    checked false
  end
end
