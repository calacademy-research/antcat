# This class is for parsing taxts in the "database format" (strings
# such as "hey {ref 123}") to something that can be read.

class TaxtPresenter
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def initialize taxt_from_db
    @taxt = taxt_from_db.try :dup
  end
  class << self; alias_method :[], :new end

  # Parses "example {tax 429361}"
  # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
  def to_html
    return '' unless @taxt
    Markdowns::ParseAntcatHooks[@taxt].html_safe
  end

  # Parses "example {tax 429361}"
  # into   "example Melophorini"
  def to_text
    parse :to_text
  end

  def to_antweb
    parse :to_antweb
  end

  private

    def parse format
      return '' if @taxt.blank?

      @format = format

      parse_refs!
      parse_nams!
      parse_taxs!

      @taxt.html_safe
    end

    # References, "{ref 123}".
    def parse_refs!
      @taxt.gsub!(/{ref (\d+)}/) do
        reference = Reference.find_by id: $1

        if reference
          case @format
          when :to_text   then reference.keey
          when :to_antweb then Exporters::Antweb::InlineCitation[reference]
          end
        else
          warn_about_non_existing_id "REFERENCE", $1
        end
      end
    end

    # Names, "{nam 123}".
    def parse_nams!
      @taxt.gsub!(/{nam (\d+)}/) do
        name = Name.find_by id: $1

        if name
          name.to_html
        else
          warn_about_non_existing_id "NAME", $1
        end
      end
    end

    # Taxa, "{tax 123}".
    def parse_taxs!
      @taxt.gsub!(/{tax (\d+)}/) do
        taxon = Taxon.find_by id: $1

        if taxon
          case @format
          when :to_text   then taxon.name.to_html
          when :to_antweb then Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
          end
        else
          warn_about_non_existing_id "TAXON", $1
        end
      end
    end

    def warn_about_non_existing_id klass, id
      "CANNOT FIND #{klass} WITH ID #{id}"
    end
end
