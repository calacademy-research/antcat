class OtherReference < Reference

  validates_presence_of :citation

  def self.import base_class_data, citation
    OtherReference.create! base_class_data.merge(:citation => citation)
  end

  def citation_string
    add_period_if_necessary citation
  end

end
