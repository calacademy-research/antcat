class Author < ActiveRecord::Base
  has_many :names, :class_name => 'AuthorName'

  scope :sorted_by_name,
    :select => 'authors.id',
    :joins => 'JOIN author_names ON author_id = authors.id',
    :group => 'authors.id',
    :order => 'name ASC'
end
