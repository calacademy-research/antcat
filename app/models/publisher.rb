class Publisher < ApplicationRecord
  belongs_to :place

  has_many :references

  validates :name, presence: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.create_with_place(name:, place_name:)
    return if name.blank?
    find_or_create_by!(name: name, place_name: place_name)
  end

  def self.create_with_place_form_string string
    parts = Parsers::PublisherParser.parse string
    create_with_place parts[:publisher] if parts
  end

  def display_name
    return name if place_name.blank?
    "#{place_name}: #{name}"
  end
end
