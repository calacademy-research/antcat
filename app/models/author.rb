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

  def merge authors_to_merge
    new_names_string = authors_to_merge.map { |author| author.names.map(&:name) }.flatten.join(", ")

    transaction do
      authors_to_merge.each do |author|
        author.names.each do |name|
          name.update(author: self)
        end
        # Reload first to avoid deleting transferred `AuthorName`s.
        author.reload.destroy
      end
    end

    create_activity :merge_authors, parameters: { names: new_names_string }
  end

  # NOTE that "first" doesn't mean "primary", or "most correct", it
  # simply refers to the name with the oldest ID.
  def first_author_name_name
    names.first&.name || '[no author name]'
  end

  def described_taxa
    Authors::DescribedTaxa[self]
  end
end
