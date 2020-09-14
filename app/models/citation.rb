# frozen_string_literal: true

class Citation < ApplicationRecord
  include OrderByPages

  ICZN_APPLICABILITY_YEAR_RANGE = 1758..9999

  belongs_to :reference

  # TODO: [grep:notes_taxt].
  has_one :protonym, inverse_of: :authorship, foreign_key: :authorship_id, dependent: :destroy

  validates :pages, presence: true

  strip_attributes only: [:pages], replace_newlines: true
  has_paper_trail

  # [grep:unify_citations].
  def citationable
    protonym
  end

  # [grep:unify_citations].
  def citation_synopsis
    "Taxon description"
  end
end
