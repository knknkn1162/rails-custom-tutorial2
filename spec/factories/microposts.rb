FactoryBot.define do
  factory :micropost do
    sequence(:content) { |n| "sample-#{n}" }
    user nil
  end
end
