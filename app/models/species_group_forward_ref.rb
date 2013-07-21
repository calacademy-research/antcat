# coding: UTF-8
class SpeciesGroupForwardRef < ForwardRef

  belongs_to :genus; validates :genus, presence: true
  validates  :epithet, presence: true

end
