# This class is for parsing taxts in the "database format" (strings
# such as "hey {ref 123}") to something that can be read.

class TaxtPresenter
  include ERB::Util
  include ActionView::Helpers::TagHelper
  include ApplicationHelper

  def initialize taxt_from_db
    @taxt = taxt_from_db.try :dup
  end
  class << self; alias_method :[], :new end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def to_html
    parse :to_html
  end

  # Parses "example {tax 429361}"
  # into   "example Melophorini"
  def to_text
    parsed = parse :to_text
    add_period_if_necessary parsed
  end

  # Not used, because we're still relying on `$use_ant_web_formatter`.
  def to_antweb
    parse :to_antweb
  end

  private
    def parse format
      return '' unless @taxt.present?

      @format = format
      maybe_enable_antweb_quirk

      parse_refs!
      parse_nams!
      parse_taxs!

      @taxt.html_safe
    end

    # References, "{ref 123}".
    def parse_refs!
      @taxt.gsub!(/{ref (\d+)}/) do
        reference = Reference.find_by id: $1
        return $1 unless reference

        case @format
        when :to_html   then reference.decorate.inline_citation
        when :to_text   then reference.decorate.keey
        when :to_antweb then reference.decorate.antweb_version_of_inline_citation
        end
      end
    end

    # Names, "{nam 123}".
    def parse_nams!
      @taxt.gsub!(/{nam (\d+)}/) do
        name = Name.find_by id: $1
        return $1 unless name

        name.to_html
      end
    end

    # Taxa, "{tax 123}".
    def parse_taxs!
      @taxt.gsub!(/{tax (\d+)}/) do
        taxon = Taxon.find_by id: $1
        return $1 unless taxon

        case @format
        when :to_html   then taxon.decorate.link_to_taxon
        when :to_text   then taxon.name.to_html
        when :to_antweb then link_to_antcat_from_antweb taxon
        end
      end
    end

    # TODO remove.
    def link_to_antcat_from_antweb taxon
      link_to_antcat taxon, taxon.name.to_html_with_fossil(taxon.fossil?).html_safe
    end

    def maybe_enable_antweb_quirk
      @format = :to_antweb if $use_ant_web_formatter
    end
end
