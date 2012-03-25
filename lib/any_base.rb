# coding: UTF-8
module AnyBase

  def self.base_10_to_base_x number, digits
    result = ''
    base = digits.length

    begin
      digit = number % base
      result.insert 0, digits[digit]
      number /= base
    end while number > 0

    result
  end

  def self.base_x_to_base_10 number, digits
    result = 0
    base = digits.length
    multiplier = 1
    index = number.length - 1
    raise unless index >= 0 
     
    begin
      digit = number[index]
      digit_value = digits.index digit
      raise unless digit_value 
      result += digit_value * multiplier
      multiplier *= base
      index -= 1
    end while index >= 0
    result
  end

end
