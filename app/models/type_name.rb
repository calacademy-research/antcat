# frozen_string_literal: true

class TypeName < ApplicationRecord
  include OrderByPages

  FIXATION_METHODS = [
    BY_MONOTYPY = 'by monotypy',
    BY_ORIGINAL_DESIGNATION = 'by original designation',
    BY_SUBSEQUENT_DESIGNATION_OF = 'by subsequent designation of'
  ]

  belongs_to :taxon
  belongs_to :reference, optional: true

  has_one :protonym, dependent: :nullify

  validates :fixation_method, inclusion: { in: FIXATION_METHODS, allow_nil: true }
  validate :ensure_subsequent_designation_of_reference, if: :by_subsequent_designation_of_fixation_method?
  validates :reference, :pages,
    absence: { message: "can only be set for 'by subsequent designation of'" },
    unless: :by_subsequent_designation_of_fixation_method?

  has_paper_trail
  strip_attributes only: [:fixation_method, :pages], replace_newlines: true

  # [grep:unify_citations].
  def citationable
    protonym
  end

  # [grep:unify_citations].
  def citation_synopsis
    case fixation_method
    when BY_SUBSEQUENT_DESIGNATION_OF
      "Subsequent designation of type name"
    else
      raise '???'
    end
  end

  private

    def by_subsequent_designation_of_fixation_method?
      fixation_method == BY_SUBSEQUENT_DESIGNATION_OF
    end

    def ensure_subsequent_designation_of_reference
      unless reference
        errors.add :reference, "must be set for 'by subsequent designation of'"
      end
      unless pages
        errors.add :pages, "must be set for 'by subsequent designation of'"
      end
    end
end
