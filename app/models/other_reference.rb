class OtherReference < Reference

  validates_presence_of :citation_string

  def self.import base_class_data, data
    OtherReference.create! base_class_data.merge(
      :series_volume_issue => data[:series_volume_issue],
      :pagination => data[:pagination],
      :journal => Journal.import(data[:journal])
    )
  end

  def citation
    add_period_if_necessary citation_string
  end

end
