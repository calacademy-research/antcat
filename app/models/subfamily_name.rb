# coding: UTF-8
class SubfamilyName < FamilyOrSubfamilyName

  def self.get_name data
    data[:subfamily_name]
  end

end
