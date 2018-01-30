FactoryBot.define do
  factory :user do
    name 'user_name'
    email 'example@gmail.com'
    password 'foobar'
    password_confirmation 'foobar'
    admin true

    # TODO: confirm the right way to generate fixtures
    factory :other do
      sequence(:name) { |n| "other_name-#{n}" }
      sequence(:email) { |n| "example_#{n}@gmail.com" }
      admin false
    end
  end
end
