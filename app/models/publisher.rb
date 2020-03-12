class Publisher < ApplicationRecord
  has_many :references, dependent: :restrict_with_error

  validates :name, :place_name, presence: true

  has_paper_trail

  def self.find_or_initialize_from_string string
    place_name, name = string.match(/(?<place_name>[^a-z:\d][^:\d]{2,})(?:: )(?<name>.+)/)&.captures
    return unless name && place_name

    find_or_initialize_by(name: name, place_name: place_name)
  end

  def display_name
    "#{place_name}: #{name}"
  end
end
