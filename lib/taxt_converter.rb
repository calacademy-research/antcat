# This class is for converting taxts between the "database format" (strings
# such as "hey {ref 123}") and the JavaScript taxt editor format,
# "hey {Bolton 2016 z6gh}".

class TaxtConverter
  # These values are duplicated in `taxt_editor.coffee`.
  REFERENCE_TAG_TYPE = 1
  TAXON_TAG_TYPE = 2
  NAME_TAG_TYPE = 3
  EDITABLE_ID_DIGITS = %{abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ}

  # TODO inline?
  class ReferenceNotFound < StandardError; end

  # TODO inline?
  # TODO maybe not used remove?
  class TaxonNotFound < StandardError; end

  # TODO inline?
  # TODO maybe not used remove?
  class NameNotFound < StandardError
    attr_accessor :id

    def initialize message = nil, id = nil
      super message
      self.id = id
    end
  end

  def initialize taxt_from_db_or_js
    @taxt = taxt_from_db_or_js || ""
  end
  class << self; alias_method :[], :new end

  def to_editor_format
    taxt = @taxt.dup
    TaxtConverter.to_editable taxt
  end

  def from_editor_format
    taxt = @taxt.dup
    TaxtConverter.from_editable taxt
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
    def self.to_editable taxt
      return '' unless taxt

      if taxt =~ /{ref/
        taxt.gsub! /{ref (\d+)}/ do |ref|
          editable_id = id_for_editable $1, REFERENCE_TAG_TYPE
          to_editable_reference Reference.find($1) rescue "{#{editable_id}}"
        end
      end

      if taxt =~ /{tax/
        taxt.gsub! /{tax (\d+)}/ do |tax|
          editable_id = id_for_editable $1, TAXON_TAG_TYPE
          to_editable_taxon Taxon.find($1) rescue "{#{editable_id}}"
        end
      end

      if taxt =~ /{nam/
        taxt.gsub! /{nam (\d+)}/ do |nam|
          editable_id = id_for_editable $1, NAME_TAG_TYPE
          to_editable_name Name.find($1) rescue "{#{editable_id}}"
        end
      end

      taxt
    end

    def self.from_editable taxt
      return '' unless taxt

      taxt.gsub /{((.*?)? )?([#{Regexp.escape EDITABLE_ID_DIGITS}]+)}/ do |string|
        id, type_number = id_from_editable $3
        case type_number
        when REFERENCE_TAG_TYPE
          raise ReferenceNotFound.new(string) unless Reference.find_by(id: id)
          "{ref #{id}}"
        when TAXON_TAG_TYPE
          raise TaxonNotFound.new(string) unless Taxon.find_by(id: id)
          "{tax #{id}}"
        when NAME_TAG_TYPE
          raise NameNotFound.new(string, id) unless Name.find_by(id: id)
          "{nam #{id}}"
        end
      end
    end

    def self.to_editable_tag id, text, type
      editable_id = id_for_editable id, type
      "{#{text} #{editable_id}}"
    end

    def self.id_for_editable id, type_number
      AnyBase.base_10_to_base_x(id.to_i * 10 + type_number, EDITABLE_ID_DIGITS).reverse
    end

    # This code is duplicated in `taxt_editor.coffee`.
    def self.id_from_editable editable_id
      number = AnyBase.base_x_to_base_10(editable_id.reverse, EDITABLE_ID_DIGITS)
      id = number / 10
      type_number = number % 10
      [id, type_number]
    end
end
