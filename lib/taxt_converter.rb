# This class is for converting taxts between the "database format" (strings
# such as "hey {ref 123}") and the JavaScript taxt editor format,
# "hey {Bolton 2016 z6gh}".

class TaxtConverter
  ReferenceNotFound = Class.new StandardError

  def initialize taxt_from_db_or_js
    @taxt = taxt_from_db_or_js.try :dup
  end
  class << self; alias_method :[], :new end

  # TODO remove rescues.
  # TODO this method used to do `if taxt =~ /{tax/` before gsubing. Investigate performance.
  def to_editor_format
    return "" unless @taxt
    taxt = @taxt.dup

    # Take all "{ref 123}" matches...
    taxt.gsub! /{ref (\d+)}/ do |ref|
      # ...generate a jumbled id: '122097, 1' --> "fDhf"
      editable_id = TaxtIdTranslator.id_for_editable $1, TaxtIdTranslator::REFERENCE_TAG_TYPE

      # ...find the reference via the id...
      reference = Reference.find($1) rescue "{#{editable_id}}"

      # ...use that reference to generate a readable label + jumbled id.
      TaxtIdTranslator.to_editable_reference reference rescue "{#{editable_id}}"
    end

    taxt.gsub! /{tax (\d+)}/ do |tax|
      editable_id = TaxtIdTranslator.id_for_editable $1, TaxtIdTranslator::TAXON_TAG_TYPE
      TaxtIdTranslator.to_editable_taxon Taxon.find($1) rescue "{#{editable_id}}"
    end

    taxt.gsub! /{nam (\d+)}/ do |nam|
      editable_id = TaxtIdTranslator.id_for_editable $1, TaxtIdTranslator::NAME_TAG_TYPE
      TaxtIdTranslator.to_editable_name Name.find($1) rescue "{#{editable_id}}"
    end

    taxt
  end

  # TODO create `SomethingTaxtError` that would encompass all errors.
  def from_editor_format
    return "" unless @taxt
    taxt = @taxt.dup

    taxt.gsub /{((.*?)? )?([#{Regexp.escape TaxtIdTranslator::EDITABLE_ID_DIGITS}]+)}/ do |string|
      id, type_number = TaxtIdTranslator.id_from_editable $3
      case type_number
      when TaxtIdTranslator::REFERENCE_TAG_TYPE
        raise ReferenceNotFound.new(string) unless Reference.find_by(id: id)
        "{ref #{id}}"
      when TaxtIdTranslator::TAXON_TAG_TYPE
        raise unless Taxon.find_by(id: id)
        "{tax #{id}}"
      when TaxtIdTranslator::NAME_TAG_TYPE
        raise unless Name.find_by(id: id)
        "{nam #{id}}"
      end
    end
  end
end
