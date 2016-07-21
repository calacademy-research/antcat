class AuthorName < ActiveRecord::Base
  include UndoTracker

  has_many :reference_author_names
  has_many :references, through: :reference_author_names
  belongs_to :author
  validates :author, :name, presence: true
  validates :name, uniqueness: true
  has_paper_trail meta: { change_id: :get_current_change_id }

  attr_accessible :name, :author, :author_id

  def last_name
    name_parts[:last]
  end

  def first_name_and_initials
    name_parts[:first_and_initials]
  end

  def self.import data
    data.map do |name|
      all.where(name: name).find { |possible_name| possible_name.name == name } ||
        create!(name: name, author: Author.create!)
    end
  end

  def self.search term = ''
    all.where('name LIKE ?', "%#{term}%").includes(:reference_author_names)
      .order('reference_author_names.created_at DESC', 'name').map(&:name)
  end

  def self.import_author_names_string string
    author_data = Parsers::AuthorParser.parse!(string)
    { author_names: import(author_data[:names]), author_names_suffix: author_data[:suffix] }
  rescue Citrus::ParseError
    { author_names: [], author_names_suffix: nil }
  end

  private
    def name_parts
      @name_parts ||= Parsers::AuthorParser.get_name_parts name
    end

end
