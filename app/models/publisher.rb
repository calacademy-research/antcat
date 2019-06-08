class Publisher < ApplicationRecord
  has_many :references, dependent: :restrict_with_error

  validates :name, :place_name, presence: true

  has_paper_trail meta: { change_id: proc { UndoTracker.get_current_change_id } }

  def self.create_form_string string
    place_name, name = string.match(/(?<place_name>[^a-z:\d][^:\d]{2,})(?:: )(?<name>.+)/)&.captures
    return unless name && place_name

    find_or_create_by!(name: name, place_name: place_name)
  end

  def display_name
    "#{place_name}: #{name}"
  end
end
