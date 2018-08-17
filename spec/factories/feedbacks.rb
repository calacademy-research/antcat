FactoryBot.define do
  factory :feedback do
    ip "127.0.0.1"
    sequence(:comment) { |n| "Great catalog! For the #{n}th time!" }
  end
end
