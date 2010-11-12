class NestedReference < Reference
  belongs_to :nested_reference, :class_name => 'Reference'

  validates_presence_of :nested_reference, :pages_in
  validate :validate_nested_reference_exists
  validate :validate_nested_reference_doesnt_point_to_itself

  def self.import base_class_data, data
    nested_reference = Reference.import data.merge(
      :id => base_class_data[:source_reference_id],
      :class => base_class_data[:source_reference_type],
      :citation_year => base_class_data[:citation_year].to_i.to_s
    )
    create! base_class_data.merge(
      :pages_in => data[:pages_in],
      :nested_reference => nested_reference
    )
  end

  def validate_nested_reference_exists
    errors.add(:nested_reference_id, 'does not exist') if nested_reference_id && !Reference.find_by_id(nested_reference_id)
  end

  def validate_nested_reference_doesnt_point_to_itself
    errors.add(:nested_reference_id, "can't point to itself") if nested_reference_id && nested_reference_id == id
  end

end
