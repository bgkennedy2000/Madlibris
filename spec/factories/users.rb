# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :email do |n|
    "email#{n}@factory.com"
  end

  sequence :username do |n|
    "username#{n}"
  end

  factory :user do
    email 
    username 
    password "Joesmith"
  end
end