# This class is for "translating" object ids jumbled strings.
# TODO merge `AnyBase` into this class.

class TaxtIdTranslator
  # These values are duplicated in `taxt_editor.coffee`.
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  # Hm, move the "label" part of these back to TaxtConverter?

  # 1) def TaxtIdTranslator[reference].to_jumbled_reference_id
  # 2) def TaxtIdTranslator[reference].jumble_id_for_editor
  def self.to_editable_reference reference
    to_editable_tag reference.id, reference.decorate.keey, REFERENCE_TAG_TYPE
  end

  # 1) def TaxtIdTranslator[taxon].to_jumbled_taxon_id
  # 2) def TaxtIdTranslator[taxon].jumble_id_for_editor
  def self.to_editable_taxon taxon
    to_editable_tag taxon.id, taxon.name, TAXON_TAG_TYPE
  end

  # 1) def TaxtIdTranslator[name].to_jumbled_name_id
  # 2) def TaxtIdTranslator[name].jumble_id_for_editor
  def self.to_editable_name name
    to_editable_tag name.id, name.name, NAME_TAG_TYPE
  end

  # These can be called from outside this file, but please don't.
  private
    def self.to_editable_tag id, text, type
      editable_id = id_for_editable id, type
      "{#{text} #{editable_id}}"
    end

    # New working name: `jumble_id_for_editor`
    def self.id_for_editable id, type_number
      jumble_any_number(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
    end

    # This code is duplicated in `taxt_editor.coffee`.
    # New working name: `id_and_type_number_from_jumbled_id_string`
    def self.id_from_editable editable_id
      number = unjumble_any_number editable_id.reverse, EDITABLE_ID_DIGITS
      id = number / 10
      type_number = number % 10
      [id, type_number]
    end

    # ex `base_10_to_base_x`
    def self.jumble_any_number number, digits
      result = ''
      base = digits.size

      begin
        digit = number % base
        result.insert 0, digits[digit]
        number /= base
      end while number > 0

      result
    end

    # ex `base_x_to_base_10`
    def self.unjumble_any_number number, digits
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
# To be continued...
