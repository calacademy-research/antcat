# frozen_string_literal: true

FactoryBot.define do
  factory :wiki_page do
    sequence(:title) { |n| "Help page no. #{n}" }
    sequence(:content, 'a') { |n| "Content is: #{n}" }

    trait :new_contributors_help_page do
      permanent_identifier { WikiPage::NEW_CONTRIBUTORS_HELP_PAGE }
    end
  end
end
