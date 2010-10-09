class Author < ActiveRecord::Base
  has_many :author_participations
  has_many :references, :through => :author_participations
  after_update :update_references

  def last_name
    parse_name
    @last_name
  end

  def first_name_and_initials
    parse_name
    @first_name_and_initials
  end

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

  def self.import_authors_string string
    import string.split(/; ?/)
  end

  private
  def parse_name
    parts = name.match(/(.*?), (.*)/)
    unless parts
      @last_name = name
    else
      @last_name = parts[1]
      @first_name_and_initials = parts[2]
    end
  end
end
