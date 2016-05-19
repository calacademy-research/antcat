FactoryGirl.define do
  factory :task, aliases: [:open_task] do
    association :adder, factory: :user
    status "open"
    title "Check synonyms"
    description "Joffre's brother told me these were synonyms."

    factory :completed_task do
      status "completed"
      association :closer, factory: :user
    end

    factory :closed_task do
      status "closed"
      association :closer, factory: :user
    end
  end
end
