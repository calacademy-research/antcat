FactoryBot.define do
  factory :author_name do
    sequence(:name) { |n| "Fisher#{n}, B.L." }
    author
  end
end
