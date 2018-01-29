FactoryBot.define do
  factory :user do
    name 'user_name'
    email 'example@gmail.com'
    password 'foobar'
    password_confirmation 'foobar'

    # TODO: confirm the right way to generate fixtures
    factory :other do
      sequence(:name) { |n| "other_name-#{n}" }
      sequence(:email) { |n| "example_#{n}@gmail.com" }
    end
  end
end
