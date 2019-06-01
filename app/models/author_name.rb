class AuthorName < ApplicationRecord
  include Trackable

  belongs_to :author

  has_many :reference_author_names
  has_many :references, through: :reference_author_names

  validates :author, :name, presence: true
  validates :name, uniqueness: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }
  trackable

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
