# frozen_string_literal: true

FactoryBot.define do
  factory :wiki_page do
    sequence(:title) { |n| "Wiki page #{n}" }
    sequence(:content, 'a') { |n| "content #{n}" }

    trait :new_contributors_help_page do
      permanent_identifier { WikiPage::NEW_CONTRIBUTORS_HELP_PAGE }
    end
  end
end
