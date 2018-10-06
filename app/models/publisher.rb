class Publisher < ApplicationRecord
  has_many :references

  validates :name, :place_name, presence: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.create_form_string string
    parts = Parsers::PublisherParser.parse string
    return unless parts

    name = parts[:publisher][:name]
    place_name = parts[:publisher][:place_name]

    find_or_create_by!(name: name, place_name: place_name)
  end

  def display_name
    "#{place_name}: #{name}"
  end
end
