FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user-email#{n}@sample.com" }
    sequence(:password) { |n| "user-password#{n}" }
  end
end
