# frozen_string_literal: true

class Journal < ApplicationRecord
  include Trackable

  has_many :references, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: { case_sensitive: true }

  has_paper_trail
  trackable parameters: proc {
    { name: name, name_was: (name_before_last_save if saved_change_to_name?) }
  }
end
