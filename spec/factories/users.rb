FactoryBot.define do
  factory :user do
    name 'user_name'
    email 'example@gmail.com'
    password 'foobar'
    password_confirmation 'foobar'
    admin true
    activated true
    activated_at { Time.zone.now }
    reset_sent_at { Time.zone.now }

    # TODO: confirm the right way to generate fixtures
    factory :other do
      sequence(:name) { |n| "other_name-#{n}" }
      sequence(:email) { |n| "example_#{n}@gmail.com" }
      admin false
    end

    factory :user_with_microposts do
      transient do
        microposts_count 5
      end

      after(:create) do |user, evaluator|
        create_list(:micropost, evaluator.microposts_count, user: user)
      end
    end
  end
end
