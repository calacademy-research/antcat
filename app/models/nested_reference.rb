# coding: UTF-8
class NestedReference < UnmissingReference
  belongs_to :nester, class_name: 'Reference'

  validates_presence_of :nester, :pages_in
  validate :validate_nested_reference_exists
  validate :validate_nested_reference_doesnt_point_to_itself

  def self.requires_title; false end

  def validate_nested_reference_exists
    errors.add(:nester_id, 'does not exist') if nester_id && !Reference.find_by_id(nester_id)
  end

  def validate_nested_reference_doesnt_point_to_itself
    comparison = self
    while comparison && comparison.nester_id
      if comparison.nester_id == id
        errors.add(:nester_id, "can't point to itself")
        break
      end
      comparison = Reference.find_by_id comparison.nester_id
    end
  end

end
