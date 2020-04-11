# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :references, dependent: :restrict_with_error

  validates :name, :place, presence: true
  validates :name, uniqueness: { case_sensitive: true, scope: [:place] }

  has_paper_trail

  def self.find_or_initialize_from_string string
    place, name = string.match(/(?<place>[^a-z:\d][^:\d]{2,})(?:: )(?<name>.+)/)&.captures
    find_or_initialize_by(name: name, place: place)
  end

  def display_name
    "#{place}: #{name}"
  end
end
