# This class is for parsing taxts in the "database format" (strings
# such as "hey {ref 123}") to something that can be read.

class TaxtPresenter
  include ActionView::Helpers::SanitizeHelper

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

  def to_antweb
    return '' if @taxt.blank?

    parse_antweb_refs!
    parse_antweb_nams!
    parse_antweb_taxs!

    sanitize @taxt.html_safe
  end

  private

    # References, "{ref 123}".
    def parse_antweb_refs!
      @taxt.gsub!(/{ref (\d+)}/) do
        reference = Reference.find_by id: $1

        if reference
          Exporters::Antweb::InlineCitation[reference]
        else
          warn_about_non_existing_id "REFERENCE", $1
        end
      end
    end

    # Names, "{nam 123}".
    def parse_antweb_nams!
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
    def parse_antweb_taxs!
      @taxt.gsub!(/{tax (\d+)}/) do
        taxon = Taxon.find_by id: $1

        if taxon
          Exporters::Antweb::Exporter.antcat_taxon_link_with_name taxon
        else
          warn_about_non_existing_id "TAXON", $1
        end
      end
    end

    def warn_about_non_existing_id klass, id
      "CANNOT FIND #{klass} WITH ID #{id}"
    end
end
