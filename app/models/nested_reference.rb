class NestedReference < Reference
  belongs_to :nested_reference, :class_name => 'Reference'

  validates_presence_of :nested_reference, :pages_in

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

end
