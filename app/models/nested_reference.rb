# coding: UTF-8
class NestedReference < Reference
  belongs_to :nested_reference, :class_name => 'Reference'

  validates_presence_of :nested_reference, :pages_in
  validate :validate_nested_reference_exists
  validate :validate_nested_reference_doesnt_point_to_itself

  def validate_nested_reference_exists
    errors.add(:nested_reference_id, 'does not exist') if nested_reference_id && !Reference.find_by_id(nested_reference_id)
  end

  def validate_nested_reference_doesnt_point_to_itself
    comparison = self
    while comparison && comparison.nested_reference_id
      if comparison.nested_reference_id == id
        errors.add(:nested_reference_id, "can't point to itself")
        break
      end
      comparison = Reference.find_by_id comparison.nested_reference_id
    end
  end

end
