class Reference < ApplicationRecord
  has_one :document, class_name: 'ReferenceDocument'

  accepts_nested_attributes_for :document, reject_if: :all_blank

  delegate :url, :downloadable?, to: :document, allow_nil: true
end
