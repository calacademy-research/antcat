# I'm not 100% *why* this is used, probably for a reason.
#
# It has to do with editing taxt items; for example,
# `TaxonHistoryItem.find(239855).taxt` is stored in the database as
# "{tax 429240}: {ref 125017}: 206.", but it looks like this in the taxt editor:
# "{Camponotini sEas}: {Forel, 1886h dopf}: 206."
#
# Showing the parsed names is obviously useful, but I'm less sure why the ids are
# converted to base_x. It's a good mystery, nevertheless.
#
# Part II:
# I guess it's to make sure "{<string> <string>}" can always be converted
# back to the correct type. But in that case showing "{tax Camponotini 429240}"
# in the taxt editor would be more intuitive, so, it's still mysterious.
#
# To be continued...

module AnyBase
  def self.base_10_to_base_x number, digits
    result = ''
    base = digits.size

    begin
      digit = number % base
      result.insert 0, digits[digit]
      number /= base
    end while number > 0

    result
  end

  def self.base_x_to_base_10 number, digits
    result = 0
    base = digits.size
    multiplier = 1
    index = number.size - 1
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
