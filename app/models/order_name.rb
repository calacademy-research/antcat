# coding: UTF-8
class OrderName < Name

  def self.get_name data
    data[:order_name]
  end

end
