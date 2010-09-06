class Author < ActiveRecord::Base
  belongs_to :source

  def self.import data
    data.inject([]) do |authors, author_name|
      authors << create!(:name => author_name)
    end
  end
end
