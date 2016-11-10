# This class is for converting taxts between the "database format" (strings
# such as "hey {ref 123}") and the JavaScript taxt editor format,
# "hey {Bolton 2016 z6gh}".

class TaxtConverter
  # These values are duplicated in `taxt_editor.coffee`.
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  ReferenceNotFound = Class.new StandardError

  def initialize taxt_from_db_or_js
    @taxt = taxt_from_db_or_js.try :dup
  end
  class << self; alias_method :[], :new end

  def to_editor_format
    return "" unless @taxt
    TaxtConverter.to_editable @taxt.dup
  end

  def from_editor_format
    return "" unless @taxt
    TaxtConverter.from_editable @taxt.dup
  end

  def self.to_editable_reference reference
    to_editable_tag reference.id, reference.decorate.keey, REFERENCE_TAG_TYPE
  end

  def self.to_editable_taxon taxon
    to_editable_tag taxon.id, taxon.name, TAXON_TAG_TYPE
  end

  def self.to_editable_name name
    to_editable_tag name.id, name.name, NAME_TAG_TYPE
  end

  # These can be called from outside this file, but please don't.
  private
    # TODO this method used to do `if taxt =~ /{tax/` before gsubing. Investigate performance.
    def self.to_editable taxt
      taxt.gsub! /{ref (\d+)}/ do |ref|
        editable_id = id_for_editable $1, REFERENCE_TAG_TYPE
        to_editable_reference Reference.find($1) rescue "{#{editable_id}}"
      end

      taxt.gsub! /{tax (\d+)}/ do |tax|
        editable_id = id_for_editable $1, TAXON_TAG_TYPE
        to_editable_taxon Taxon.find($1) rescue "{#{editable_id}}"
      end

      taxt.gsub! /{nam (\d+)}/ do |nam|
        editable_id = id_for_editable $1, NAME_TAG_TYPE
        to_editable_name Name.find($1) rescue "{#{editable_id}}"
      end

      taxt
    end

    # TODO create `SomethingTaxtError` that would encompass all errors.
    def self.from_editable taxt
      taxt.gsub /{((.*?)? )?([#{Regexp.escape EDITABLE_ID_DIGITS}]+)}/ do |string|
        id, type_number = id_from_editable $3
        case type_number
        when REFERENCE_TAG_TYPE
          raise ReferenceNotFound.new(string) unless Reference.find_by(id: id)
          "{ref #{id}}"
        when TAXON_TAG_TYPE
          raise unless Taxon.find_by(id: id)
          "{tax #{id}}"
        when NAME_TAG_TYPE
          raise unless Name.find_by(id: id)
          "{nam #{id}}"
        end
      end
    end

    def self.to_editable_tag id, text, type
      editable_id = id_for_editable id, type
      "{#{text} #{editable_id}}"
    end

    # TODO extract this + related + `AnyBase` into a new class `TaxtIdTranslator`.
    # New working name: `id_from_jumbled_id`
    def self.id_for_editable id, type_number
      AnyBase.base_10_to_base_x(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
    end

    # This code is duplicated in `taxt_editor.coffee`.
    # New working name: `id_from_jumbled_id`
    def self.id_from_editable editable_id
      number = AnyBase.base_x_to_base_10(editable_id.reverse, EDITABLE_ID_DIGITS)
      id = number / 10
      type_number = number % 10
      [id, type_number]
    end
end
