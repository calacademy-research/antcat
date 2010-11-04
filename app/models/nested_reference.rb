class NestedReference < Reference
  belongs_to :nested_reference, :class_name => 'Reference'

  validates_presence_of :nested_reference, :pages_in

  def self.import base_class_data, data
    nested_reference = Reference.import data.merge(:citation_year => base_class_data[:citation_year].to_i.to_s)
    create! base_class_data.merge(
      :pages_in => data[:pages_in],
      :nested_reference => nested_reference
    )
  rescue StandardError => e
    puts e
    raise
  end

  #def citation_string
    #Reference.add_period_if_necessary "#{publisher}, #{pagination}"
  #end

end
