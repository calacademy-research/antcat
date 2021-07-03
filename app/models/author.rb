# frozen_string_literal: true

class Author < ApplicationRecord
  include Trackable

  has_one :user, dependent: :nullify
  has_many :names, class_name: 'AuthorName', dependent: :destroy
  has_many :references, through: :names, dependent: :restrict_with_error

  scope :order_by_name, -> { joins(:names).group('authors.id').order(Arel.sql('MAX(name)')) }

  has_paper_trail
  trackable

  # NOTE: "first" doesn't mean "primary", or "most correct", it
  # simply refers to the name with the oldest ID.
  def first_author_name_name
    names.first&.name || '[no author name]'
  end

  def only_has_one_name?
    names.count <= 1
  end

  def described_taxa
    Taxon.joins(protonym: { authorship: { reference: :authors } }).where(authors: { id: id })
  end

  def described_protonyms
    Protonym.joins(authorship: { reference: :authors }).where(authors: { id: id })
  end
end
