class Author < ActiveRecord::Base
  has_many :names, -> { order(:name) }, class_name: 'AuthorName'
  has_many :references, through: :names

  scope :sorted_by_name, -> do
    select('authors.id').joins(:names).group('authors.id').order('name')
  end

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.find_by_names names
    Author.joins(:names).where('name IN (?)', names).group('authors.id').to_a
  end

  def self.merge authors
    new_names_string = get_author_names_for_feed_message authors
    the_one_author = authors.first

    transaction do
      authors[1..-1].each do |author|
        author.names.each do |name|
          name.update_attribute :author, the_one_author
        end
        author.destroy
      end
    end

    create_merge_authors_activity the_one_author, new_names_string
  end

  # NOTE that "first" doesn't mean "primary", or "most correct", it
  # simply refers to the name with the oldest ID.
  # TODO maybe we want a way to reorder these.
  def first_author_name_name
    names.first.name
  end

  def described_taxa
    Authors::DescribedTaxa.new(self).call
  end

  private
    def self.create_merge_authors_activity author, names_string
      Activity.create_for_trackable author, :merge_authors, names: names_string
    end
    private_class_method :create_merge_authors_activity

    def self.get_author_names_for_feed_message authors
      authors[1..-1].map do |author|
        author.names.map(&:name)
      end.flatten.join(", ")
    end
    private_class_method :get_author_names_for_feed_message
end
