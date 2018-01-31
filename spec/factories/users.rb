FactoryBot.define do
  factory :user do
    name 'user_name'
    email 'example@gmail.com'
    password 'foobar'
    password_confirmation 'foobar'
    admin true
    acticated true
    activated_at { Time.zone.now }

    # TODO: confirm the right way to generate fixtures
    factory :other do
      sequence(:name) { |n| "other_name-#{n}" }
      sequence(:email) { |n| "example_#{n}@gmail.com" }
      admin false
      sequence(:activated_at) { Time.zone.now }
    end
  end
end
