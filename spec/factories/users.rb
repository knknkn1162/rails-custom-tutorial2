FactoryBot.define do
  factory :user do
    name 'user_name'
    email 'example@gmail.com'

    # TODO: confirm the right way to generate fixtures
    factory :other do
      name 'other_name'
      sequence(:email) { |n| "example_#{n}@gmail.com" }
    end
  end
end
