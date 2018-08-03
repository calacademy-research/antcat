class Reference < ApplicationRecord
  has_one :document, class_name: 'ReferenceDocument'

  accepts_nested_attributes_for :document, reject_if: :all_blank

  delegate :url, :downloadable?, to: :document, allow_nil: true

  def document_host= host
    document.host = host if document
  end
end
