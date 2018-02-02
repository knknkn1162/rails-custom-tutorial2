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
  end
end
