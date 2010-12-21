class AuthorName < ActiveRecord::Base
  has_many :reference_author_names
  has_many :references, :through => :reference_author_names
  after_update :update_references

  belongs_to :author
  validates_presence_of :author

  def last_name
    name_parts[:last]
  end

  def first_name_and_initials
    name_parts[:first_and_initials]
  end

  def self.import data
    data.inject([]) do |author_names, name|
      author_name = find_by_name(name) || AuthorName.create!(:name => name, :author => Author.create!)
      author_names << author_name
    end
  end

  def self.search term = ''
    all(:conditions => ["name LIKE ?", "%#{term}%"], :include => :reference_author_names,
        :order => 'reference_author_names.created_at DESC, name').map(&:name)
  end

  def update_references
    references.each {|reference| reference.update_author_names_caches}
  end

  def self.import_author_names_string string
    author_data = Ward::AuthorParser.parse(string)
    {:author_names => import(author_data[:names]), :author_names_suffix => author_data[:suffix]}
  rescue Citrus::ParseError
    {:author_names => [], :author_names_suffix => nil}
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

  def self.alias show_progress, *names
    Progress.init show_progress
    names = names.map do |name|
      author_name = nil
      unless author_name = find_by_name(name)
        author_name = Factory :author_name, :name => name
      end
      author_name
    end
    author = names.first.author
    names[1..-1].each do |name|
      Progress.puts "Aliasing '#{name.name}' to '#{names.first.name}'"
      update_all({:author_id => author.id}, {:author_id => name.author_id})
      name.author.destroy unless name.author.names(true).present?
    end
  end

  def self.correct bad, good, show_progress = true
    Progress.init show_progress
    Progress.print "Correcting '#{bad}' to '#{good}'..."
    bad_name = find_by_name bad
    raise unless bad_name
    existing_name = find_by_name good
    if existing_name
      Progress.puts 'which already exists'
      references = bad_name.references.dup
      ReferenceAuthorName.all(:conditions => ['author_name_id = ?', bad_name.id]).each do |e|
        e.author_name_id = existing_name.id
        e.save!
      end
      author = bad_name.author
      bad_name.destroy
      author.destroy unless author.names.present?
      references.each do |reference|
        Progress.puts "Changed #{reference}"
        reference.update_author_names_caches
        Progress.puts "     to #{reference}"
      end
    else
      Progress.puts "which doesn't exist"
      bad_name.name = good
      bad_name.save!
    end
  end

  def self.find_preposition_synonyms show_progress = false
    synonyms = []
    all.each do |author_name|
      name = author_name.name.dup
      match = name.match /^((?:La|Le|De) )(.*)/i
      next unless match

      name_without_space = name.gsub! /^#{match[1]}/, match[1][0..-2]
      if (author_name_without_space = find_by_name(name_without_space)) &&
         author_name_without_space.author != author_name.author
        synonyms << [author_name, author_name_without_space]
      end

      name = author_name.name.dup
      name[0, match[1].length] = ''
      name << ', ' + match[1]
      name_with_preposition_at_end = name
      if (author_name_with_preposition_at_end = find_by_name(name_with_preposition_at_end)) &&
         author_name_with_preposition_at_end.author != author_name.author
        synonyms << [author_name, author_name_with_preposition_at_end]
      end
    end
    synonyms
  end

  private
  def name_parts
    @name_parts ||= AuthorParser.get_name_parts name
  end

end
