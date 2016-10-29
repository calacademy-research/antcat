class Author < ActiveRecord::Base
  include UndoTracker

  has_many :names, -> { order :name }, class_name: 'AuthorName'
  scope :sorted_by_name, -> { select('authors.id').joins(:names).group('authors.id').order('name') }

  has_paper_trail meta: { change_id: :get_current_change_id }

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

  # TODO add `private_class_method :xxx`
  private
    def self.create_merge_authors_activity author, names_string
      Feed::Activity.create_activity_for_trackable author,
        :merge_authors, names: names_string
    end

    def self.get_author_names_for_feed_message authors
      authors[1..-1].map do |author|
        author.names.map(&:name)
      end.flatten.join(", ")
    end
end
