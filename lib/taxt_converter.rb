# This class is for converting taxts between the "database format" (strings
# such as "hey {ref 123}") and the JavaScript taxt editor format,
# "hey {Bolton 2016 z6gh}".

class TaxtConverter
  ReferenceNotFound = Class.new StandardError

  def initialize taxt_from_db_or_js
    @taxt = taxt_from_db_or_js.try :dup
  end
  class << self; alias_method :[], :new end

  # If we cannot find the reference/taxon/name, we must still jumble the id
  # or things will happen.
  def to_editor_format
    return "" unless @taxt
    taxt = @taxt.dup

    taxt.gsub! /{ref (\d+)}/ do |_match|
      if reference = Reference.find_by(id: $1)
        TaxtIdTranslator.to_editor_ref_tag reference
      else
        jumbled_id = TaxtIdTranslator.jumble_id $1, TaxtIdTranslator::REFERENCE_TAG_TYPE
        "{#{jumbled_id}}"
      end
    end

    taxt.gsub! /{tax (\d+)}/ do |_match|
      if taxon = Taxon.find_by(id: $1)
        TaxtIdTranslator.to_editor_tax_tag taxon
      else
        jumbled_id = TaxtIdTranslator.jumble_id $1, TaxtIdTranslator::TAXON_TAG_TYPE
        "{#{jumbled_id}}"
      end
    end

    taxt.gsub! /{nam (\d+)}/ do |_match|
      if name = Name.find_by(id: $1)
        TaxtIdTranslator.to_editor_nam_tag name
      else
        jumbled_id = TaxtIdTranslator.jumble_id $1, TaxtIdTranslator::NAME_TAG_TYPE
        "{#{jumbled_id}}"
      end
    end

    taxt
  end

  # TODO create `SomethingTaxtError` that would encompass all errors.
  def from_editor_format
    return "" unless @taxt
    taxt = @taxt.dup

    taxt.gsub /{((.*?)? )?([#{Regexp.escape TaxtIdTranslator::JUMBLED_ID_DIGITS}]+)}/ do |string|
      id, type_number = TaxtIdTranslator.unjumble_id_and_type $3
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
