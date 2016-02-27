class NestedReference < UnmissingReference
  belongs_to :nesting_reference, class_name: 'Reference'

  validates_presence_of :nesting_reference, :pages_in
  validate :validate_nested_reference_exists
  validate :validate_nested_reference_doesnt_point_to_itself
  attr_accessible :nesting_reference, :year

  def self.requires_title; false end

  def validate_nested_reference_exists
    errors.add(:nesting_reference_id, 'does not exist') if nesting_reference_id && !Reference.find_by_id(nesting_reference_id)
  end

  def validate_nested_reference_doesnt_point_to_itself
    comparison = self
    while comparison && comparison.nesting_reference_id
      if comparison.nesting_reference_id == id
        errors.add(:nesting_reference_id, "can't point to itself")
        break
      end
      comparison = Reference.find_by_id comparison.nesting_reference_id
    end
  end

end
