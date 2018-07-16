# This class is for "translating" object ids to jumbled strings (in base 62).

class TaxtIdTranslator
  # These values are duplicated in `taxt_editor.coffee`.
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3
  JUMBLED_ID_DIGITS = "abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

  # The "label" part of these does not belong here, but we should probably remake
  # this whole thing before dealing with that.
  # ex `to_editable_reference`
  def self.to_editor_ref_tag reference
    to_editor_tag reference.id, reference.keey, REFERENCE_TAG_TYPE
  end

  # ex `to_editable_taxon`
  def self.to_editor_tax_tag taxon
    to_editor_tag taxon.id, taxon.name, TAXON_TAG_TYPE
  end

  # ex `to_editable_name`
  def self.to_editor_nam_tag name
    to_editor_tag name.id, name.name, NAME_TAG_TYPE
  end

  # These can be called from outside this file, but please avoid.

  private

    # ex `to_editable_tag`
    def self.to_editor_tag id, text, type
      jumbled_id = jumble_id id, type
      "{#{text} #{jumbled_id}}"
    end

    # ex `id_for_editable`
    def self.jumble_id id, type_number
      base_10_to_base_x(id.to_i * 10 + type_number, JUMBLED_ID_DIGITS).reverse
    end

    # This code is duplicated in `taxt_editor.coffee`.
    # ex `id_from_editable`
    def self.unjumble_id_and_type jumbled_id
      number = base_x_to_base_10 jumbled_id.reverse, JUMBLED_ID_DIGITS
      id = number / 10
      type_number = number % 10
      [id, type_number]
    end

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

# Investigation notes from `module AnyBase`
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
# Part III:
# Ok, so maybe we should just remove this whole jumbling thing?
#
# To be continued...
