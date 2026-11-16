# frozen_string_literal: true

FactoryBot.define do
  factory :notes_page do
    association :protonym
    sequence(:content) { |n| "## Etymological notes\n\nNotes #{n}." }
  end
end
