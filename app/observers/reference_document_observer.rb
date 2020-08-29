# frozen_string_literal: true

class ReferenceDocumentObserver < ActiveRecord::Observer
  def before_update reference_document
    return unless (reference = reference_document&.reference)
    References::Cache::Invalidate[reference]
  end
end
