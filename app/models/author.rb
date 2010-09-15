class Author < ActiveRecord::Base
  has_many :author_participations
  has_many :references, :through => :author_participations
  after_update :update_references

  def self.import data
    data.inject([]) do |authors, author_name|
      authors << find_or_create_by_name(author_name)
    end
  end

  def update_references
    references.each {|reference| reference.update_authors_string}
  end
end
