# TODO `remove_column :author_names, :verified`, or rename to `auto_generated`.

class AuthorName < ActiveRecord::Base
  belongs_to :author

  has_many :reference_author_names
  has_many :references, through: :reference_author_names

  validates :author, :name, presence: true
  validates :name, uniqueness: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  # TODO rename.
  def self.import data
    data.map do |name|
      all.where(name: name).find { |possible_name| possible_name.name == name } ||
        create!(name: name, author: Author.create!)
    end
  end

  def self.import_author_names_string string
    author_data = Parsers::AuthorParser.parse!(string)
    { author_names: import(author_data[:names]), author_names_suffix: author_data[:suffix] }
  rescue Citrus::ParseError
    { author_names: [], author_names_suffix: nil }
  end

  def last_name
    name_parts[:last]
  end

  def first_name_and_initials
    name_parts[:first_and_initials]
  end

  private
    def name_parts
      @name_parts ||= Parsers::AuthorParser.get_name_parts name
    end
end
