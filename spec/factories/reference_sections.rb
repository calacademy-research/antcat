FactoryGirl.define do
  factory :reference_section do
    association :taxon
    sequence(:position) { |n| n }
    sequence(:references_taxt) { |n| "Reference #{n}" }
  end
end
