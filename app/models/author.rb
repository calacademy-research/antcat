class Author < ActiveRecord::Base
  has_many :author_participations
  has_many :references, :through => :author_participations
  after_update :update_references

  def self.import data
    data.inject([]) do |authors, author_name|
      authors << find_or_create_by_name(author_name)
    end
  end

  def self.search term = ''
    all(:conditions => ["name LIKE ?", "%#{term}%"], :include => :author_participations,
        :order => 'author_participations.created_at DESC, name').map(&:name)
  end

  def update_references
    references.each {|reference| reference.update_authors_string}
  end

  def self.parse_authors_string string
    import string.split(/; ?/)
  end

end
