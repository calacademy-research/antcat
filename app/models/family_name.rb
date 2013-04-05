# coding: UTF-8
class FamilyName < FamilyOrSubfamilyName

  def self.get_name data
    data[:family_name]
  end

end
