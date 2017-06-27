FactoryGirl.define do
  factory :activity do
    user factory: :user
    trackable factory: :journal
    action "create"
  end

  factory :comment do
    body "A comment"
    user
    association :commentable, factory: :issue

    factory :reply do
      association :parent, factory: :comment
      body "OK, makes sense"
    end
  end

  factory :feedback do
    ip "127.0.0.1"
    comment "Great catalog!"
  end

  factory :issue do
    association :adder, factory: :user
    open true
    title "Check synonyms"
    description "Joffre's brother told me these were synonyms."

    trait :open do
    end

    trait :closed do
      open false
      association :closer, factory: :user
    end
  end

  factory :site_notice do
    title "Site notice title"
    message "Site notice message"
    association :user, factory: :user
  end

  factory :tooltip do
    sequence(:key) { |n| "test.key#{n}" }
    sequence(:text) { |n| "Tooltip text #{n}" }
  end
end

class DatabaseTestScript
  include DatabaseScripts::DatabaseScript

  def results
    Reference.all
  end
end
