FactoryGirl.define do
  trait :access_common do
    sequence(:uid) { |n| "oauth-uid#{n}" }
    sequence(:email) { |n| "oauth-email#{n}@sample.com" }
    sequence(:name) { |n| "oauth-name#{n}" }
    sequence(:state) { |n| "oauth-state#{n}" }
    sequence(:code) { |n| "oauth-code#{n}" }
    sequence(:token) { |n| "oauth-token#{n}" }
    expires true
    expires_at 1502227013
  end

  factory :access do
    access_common
    user
    trait :google_oauth2 do
      provider "google_oauth2"
    end
  end
end
