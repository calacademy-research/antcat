class Author < ActiveRecord::Base
  has_many :names, :class_name => 'AuthorName'
end
