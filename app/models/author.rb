# coding: UTF-8
class Author < ActiveRecord::Base
  has_many :names, :class_name => 'AuthorName'
  scope :sorted_by_name, select('authors.id').joins(:names).group('authors.id').order(:name)

  def self.find_by_names names
    results = Author.select('authors.id').
      joins(:names).
      where('name IN (?)', names)
    results.group('authors.id')
  end
end
