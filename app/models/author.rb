class Author < ActiveRecord::Base
  include UndoTracker

  has_many :names, -> { order :name }, class_name: 'AuthorName'
  scope :sorted_by_name, -> { select('authors.id').joins(:names).group('authors.id').order('name') }
  attr_accessible :names

  has_paper_trail meta: { change_id: :get_current_change_id }

  def self.find_by_names names
    Author.joins(:names).where('name IN (?)', names).group('authors.id').to_a
  end

  def self.merge authors
    transaction do
      the_one_author = authors.first
      authors[1..-1].each do |author|
        author.names.each do |name|
          name.update_attribute :author, the_one_author
        end
        author.destroy
      end
    end
  end

end
