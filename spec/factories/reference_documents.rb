# frozen_string_literal: true

FactoryBot.define do
  factory :reference_document do
    trait :with_file do
      file { File.new(Rails.root.join('spec/fixtures/test_pdf.pdf')) }
      url { nil }
    end

    trait :with_reference do
      reference factory: :any_reference
    end
  end
end
