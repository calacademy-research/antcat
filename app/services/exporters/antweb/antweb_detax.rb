module Exporters
  module Antweb
    class AntwebDetax
      include ActionView::Helpers::SanitizeHelper
      include Service

      def initialize taxt
        @taxt = taxt.try :dup
      end

      # Parses "example {tax 429361}"
      # into   "example <a href=\"/catalog/429361\">Melophorini</a>"
      def call
        return '' if taxt.blank?

        parse_antweb_refs!
        parse_antweb_taxs!

        sanitize taxt.html_safe
      end

      private

        attr_reader :taxt

        # References, "{ref 123}".
        def parse_antweb_refs!
          taxt.gsub!(/{ref (\d+)}/) do
            reference = Reference.find_by(id: $1)

            if reference
              Exporters::Antweb::AntwebInlineCitation[reference]
            else
              warn_about_non_existing_id "REFERENCE", $1
            end
          end
        end

        # Taxa, "{tax 123}".
        def parse_antweb_taxs!
          taxt.gsub!(/{tax (\d+)}/) do
            taxon = Taxon.find_by(id: $1)

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
  end
end
