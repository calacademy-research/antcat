class Author < ApplicationRecord
  has_many :names, class_name: 'AuthorName'
  has_many :references, through: :names, dependent: :restrict_with_error

  scope :sorted_by_name, -> { joins(:names).group('authors.id').order(Arel.sql('MAX(name)')) }

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.find_by_names names
    Author.joins(:names).where('name IN (?)', names).group('authors.id').to_a
  end

  def self.merge target_author, authors_to_merge
    new_names_string = authors_to_merge.map { |author| author.names.map(&:name) }.flatten.join(", ")

    transaction do
      authors_to_merge.each do |author|
        author.names.each do |name|
          name.update_attribute :author, target_author
        end
        author.destroy
      end
    end

    create_merge_authors_activity target_author, new_names_string
  end

  # NOTE that "first" doesn't mean "primary", or "most correct", it
  # simply refers to the name with the oldest ID.
  def first_author_name_name
    names.first.name
  end

  def described_taxa
    Authors::DescribedTaxa[self]
  end

  private

    def self.create_merge_authors_activity author, names_string
      Activity.create_for_trackable author, :merge_authors, parameters: { names: names_string }
    end
    private_class_method :create_merge_authors_activity
end
