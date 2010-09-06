class Author < ActiveRecord::Base
  belongs_to :source

  def self.import data
    data.inject([]) do |authors, author_name|
      authors << find_or_create_by_name(author_name)
    end
  end
end
