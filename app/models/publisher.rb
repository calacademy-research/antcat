class Publisher < ActiveRecord::Base
  belongs_to :place

  has_many :references

  validates_presence_of :name

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.create_with_place(name:, place:)
    return unless name.present?
    place_record = Place.find_or_create_by!(name: place)
    find_or_create_by!(name: name, place: place_record)
  end

  def self.create_with_place_form_string string
    parts = Parsers::PublisherParser.parse string
    create_with_place parts[:publisher] if parts
  end

  def display_name
    return name unless place.present?
    "#{place.name}: #{name}"
  end
end
