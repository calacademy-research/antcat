# coding: UTF-8
class Author < ActiveRecord::Base
  has_many :names, :class_name => 'AuthorName'
  scope :sorted_by_name, select('authors.id').joins(:names).group('authors.id').order(:name)

  def self.find_by_names names
    Author.joins(:names).where('name IN (?)', names).group('authors.id').to_a
  end

  def self.merge authors
    transaction do
      the_one_author = authors.first
      for author in authors[1..-1]
        for name in author.names
          name.update_attribute :author, the_one_author
        end
        author.destroy
      end
    end
  end

end
