class AuthorName < ActiveRecord::Base
  has_many :reference_author_names
  has_many :references, :through => :reference_author_names
  after_update :update_references
  belongs_to :author

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
    all(:conditions => ["name LIKE ?", "%#{term}%"], :include => :reference_author_names,
        :order => 'reference_author_names.created_at DESC, name').map(&:name)
  end

  def update_references
    references.each {|reference| reference.update_author_names_string}
  end

  def self.import_author_names_string string
    author_data = AuthorParser.parse(string)
    {:author_names => import(author_data[:names]), :author_names_suffix => author_data[:suffix]}
  end

  def self.fix_missing_spaces show_progress = false
    Progress.init show_progress
    missing_space_pattern = /\.([^ ,\-])/
    all.each do |author_name|
      name = author_name.name.dup
      next unless name =~ missing_space_pattern
      name.gsub! missing_space_pattern, '. \1'
      Progress.print "Changing '#{author_name.name}' to '#{name}'..."
      existing_author_name = find_by_name name
      if existing_author_name
        Progress.print "which already exists"
        author_name.references.each do |reference|
          reference.author_names.delete author_name
          reference.author_names << existing_author_name
          author_name.destroy
        end
      else
        Progress.print "which doesn't already exist"
        author_name.name = name
        author_name.save!
      end
      Progress.puts
    end
  end

  def self.create_hyphenation_aliases show_progress = false
    Progress.init show_progress
    all(:order => 'name').each do |author_name|
      next unless author_name.name =~ /-/
      Progress.puts
      Progress.print "Found name with hyphen(s): '#{author_name.name}'"
      next unless without_hyphens = find_by_name(author_name.name.gsub /-/, ' ')
      next if author_name.author == without_hyphens.author
      Progress.print "...aliasing to '#{without_hyphens.name}'"
      author_name.author.destroy
      author_name.author = without_hyphens.author
      author_name.save!
    end
  end

  private
  def name_parts
    @name_parts ||= AuthorParser.get_name_parts name
  end

end
