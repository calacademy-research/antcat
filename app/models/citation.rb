# frozen_string_literal: true

# This class is currently only used in `Protonym`, where the association
# is called `authorship`. I believe the plan was to use this in more places,
# say in taxt items, but that never happened. We may want to rename
# `protonyms.authorship_id` in any case.

class Citation < ApplicationRecord
  belongs_to :reference

  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :destroy

  validates :pages, presence: true

  before_validation :cleanup_taxts

  strip_attributes only: [:notes_taxt, :pages, :forms], replace_newlines: true
  has_paper_trail

  private

    def cleanup_taxts
      self.notes_taxt = Taxt::Cleanup[notes_taxt]
    end
end
