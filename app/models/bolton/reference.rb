class Bolton::Reference < ActiveRecord::Base
  belongs_to :reference
  set_table_name :bolton_references
  before_validation :set_year

  def self.match_against_ward show_progress = false
    Bolton::ReferenceMatcher.new(show_progress).match_all
  end

  def to_s
    "#{authors} #{year}. #{title}."
  end

  def set_year
    self.year = ::Reference.get_year citation_year
  end 
end
