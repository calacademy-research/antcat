class Place < ActiveRecord::Base
  include UndoTracker

  validates_presence_of :name
  has_paper_trail meta: { change_id: :get_current_change_id }

  attr_accessible :name

  def self.import name
    find_or_create_by!(name: name)
  end

end
