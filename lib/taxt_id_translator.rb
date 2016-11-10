# This class is for "translating" object ids jumbled strings.
# TODO merge `AnyBase` into this class.

class TaxtIdTranslator
  # These values are duplicated in `taxt_editor.coffee`.
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

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
      AnyBase.base_10_to_base_x(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
    end

    # This code is duplicated in `taxt_editor.coffee`.
    # New working name: `id_and_type_number_from_jumbled_id_string`
    def self.id_from_editable editable_id
      number = AnyBase.base_x_to_base_10 editable_id.reverse, EDITABLE_ID_DIGITS
      id = number / 10
      type_number = number % 10
      [id, type_number]
    end
end
