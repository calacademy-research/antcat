class BoltonReference < ActiveRecord::Base
  belongs_to :reference

  def self.match_against_ward show_progress = false
    Bolton::ReferenceMatcher.new(show_progress).match_all
  end

  def to_s
    "#{authors} #{year}. #{title_and_citation}."
  end
end
