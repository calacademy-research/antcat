# coding: UTF-8
class CollectiveGroupName < GenusGroupName

  def self.get_name data
    data[:collective_group_name]
  end

end
