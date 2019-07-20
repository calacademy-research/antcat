class Author < ApplicationRecord
  include Trackable

  has_many :names, class_name: 'AuthorName', dependent: :destroy
  has_many :references, through: :names, dependent: :restrict_with_error

  scope :sorted_by_name, -> { joins(:names).group('authors.id').order(Arel.sql('MAX(name)')) }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  trackable

  def self.find_by_names names
    Author.joins(:names).where('name IN (?)', names).group('authors.id').to_a
  end

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
end
