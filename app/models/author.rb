class Author < ActiveRecord::Base
  has_many :names, :class_name => 'AuthorName'
  scope :sorted_by_name, select('authors.id').joins(:names).group('authors.id').order(:name)
end
