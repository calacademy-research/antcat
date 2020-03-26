# frozen_string_literal: true

class Author < ApplicationRecord
  include Trackable

  has_many :names, class_name: 'AuthorName', dependent: :destroy
  has_many :references, through: :names, dependent: :restrict_with_error

  scope :sorted_by_name, -> { joins(:names).group('authors.id').order(Arel.sql('MAX(name)')) }

  has_paper_trail
  trackable

  def merge author_to_merge
    transaction do
      author_to_merge.names.each do |name|
        name.update!(author: self)
      end
      author_to_merge.reload.destroy # Reload first to avoid deleting transferred `AuthorName`s.
    end
  end

  # NOTE: "first" doesn't mean "primary", or "most correct", it
  # simply refers to the name with the oldest ID.
  def first_author_name_name
    names.first&.name || '[no author name]'
  end

  def described_taxa
    Taxon.joins(protonym: { authorship: { reference: :authors } }).where(authors: { id: id })
  end

  # TODO: This makes more sense than `#described_taxa` (which includes combinations).
  # What we really want is "terminal" taxa (at least valid and synonyms, probably other statuses too).
  def described_protonyms
    Protonym.joins(authorship: { reference: :authors }).where(authors: { id: id })
  end
end
