FactoryGirl.define do
  factory :issue, aliases: [:open_issue] do
    association :adder, factory: :user
    status "open"
    title "Check synonyms"
    description "Joffre's brother told me these were synonyms."

    factory :completed_issue do
      status "completed"
      association :closer, factory: :user
    end

    factory :closed_issue do
      status "closed"
      association :closer, factory: :user
    end
  end
end
