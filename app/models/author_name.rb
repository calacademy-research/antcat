class AuthorName < ActiveRecord::Base
  has_many :author_participations
  has_many :references, :through => :author_participations
  after_update :update_references

  def last_name
    name_parts[:last]
  end

  def first_name_and_initials
    name_parts[:first_and_initials]
  end

  def self.import data
    data.inject([]) do |author_names, author_name|
      author_names << find_or_create_by_name(author_name)
    end
  end

  def self.search term = ''
    all(:conditions => ["name LIKE ?", "%#{term}%"], :include => :author_participations,
        :order => 'author_participations.created_at DESC, name').map(&:name)
  end

  def update_references
    references.each {|reference| reference.update_author_names_string}
  end

  def self.import_author_names_string string
    author_data = AuthorParser.parse(string)
    {:author_names => import(author_data[:names]), :author_names_suffix => author_data[:suffix]}
  end

  private

  def name_parts
    @name_parts ||= AuthorParser.get_name_parts name
  end

end
