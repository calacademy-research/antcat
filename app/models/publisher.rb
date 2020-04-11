# frozen_string_literal: true

class Publisher < ApplicationRecord
  has_many :references, dependent: :restrict_with_error

  validates :name, :place, presence: true
  validates :name, uniqueness: { case_sensitive: true, scope: [:place] }

  has_paper_trail

  def self.place_and_name_from_string string
    place, name = string.match(/(?<place>[^a-z:\d][^:\d]{2,})(?:: )(?<name>.+)/)&.captures
    { place: place, name: name }
  end

  def display_name
    "#{place}: #{name}"
  end
end
