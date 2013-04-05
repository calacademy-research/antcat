# coding: UTF-8
class FamilyOrSubfamilyName < Name

  def self.get_name data
    data[:family_or_subfamily_name]
  end

end
