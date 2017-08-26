FactoryGirl.define do
  factory :reference_author_name do
    association :reference
    association :author_name
  end
end
