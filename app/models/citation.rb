# frozen_string_literal: true

# This class is currently only used in `Protonym`, where the association
# is called `authorship`. I believe the plan was to use this in more places,
# say in taxt items, but that never happened. We may want to rename
# `protonyms.authorship_id` in any case.

class Citation < ApplicationRecord
  belongs_to :reference

  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :restrict_with_error

  validates :pages, presence: true
  validate :no_missing_references

  before_validation :cleanup_taxts

  strip_attributes only: [:notes_taxt, :pages, :forms], replace_newlines: true
  has_paper_trail

  private

    def cleanup_taxts
      self.notes_taxt = Taxt::Cleanup[notes_taxt]
    end

    def no_missing_references
      return unless reference.is_a? MissingReference
      errors.add :reference, "cannot be a missing reference"
    end
end
