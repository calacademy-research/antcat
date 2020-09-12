# frozen_string_literal: true

class Journal < ApplicationRecord
  include Trackable

  has_many :references, dependent: :restrict_with_error

  # TODO: Make case insensitive (and Ctrl+F case_sensitive).
  validates :name, presence: true, uniqueness: { case_sensitive: true }

  has_paper_trail
  trackable parameters: proc {
    { name: name, name_was: (name_before_last_save if saved_change_to_name?) }
  }

  def invalidate_reference_caches
    references.find_each do |reference|
      References::Cache::Invalidate[reference]
    end
  end
end
