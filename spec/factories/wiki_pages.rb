FactoryBot.define do
  factory :wiki_page do
    sequence(:title) { |n| "Help page no. #{n}" }
    sequence(:content, 'a') { |n| "Content is: #{n}" }

    trait :new_contributors_help_page do
      id { My::RegistrationsController::NEW_CONTRIBUTORS_HELP_PAGE_WIKI_PAGE_ID }
    end
  end
end
