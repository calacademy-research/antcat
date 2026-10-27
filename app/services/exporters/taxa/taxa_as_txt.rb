# frozen_string_literal: true

module Exporters
  module Taxa
    class TaxaAsTxt
      include Service

      attr_private_initialize :taxa

      def call
        taxa.reduce(+'') do |content, taxon|
          content << format_taxon(taxon)
        end
      end

      private

        def format_taxon taxon
          type_localities = format_type_localities(taxon)

          # A copy, so `<<` does not change the taxon's `name_cache`. Plain text: nothing is HTML-escaped.
          string = format_name(taxon).to_s.dup
          string << ' '
          string << format_status(taxon)
          string << (' ' + type_localities) if type_localities.present?
          string << "\n"
          string << format_protonym(taxon)
          string << "\n\n"
        end

        def format_name taxon
          taxon.name_cache
        end

        def format_status taxon
          labels = []
          labels << "incertae sedis in #{taxon.incertae_sedis_in.downcase}" if taxon.incertae_sedis_in
          labels << main_status(taxon)
          labels.join(', ').html_safe
        end

        def main_status taxon
          if taxon.homonym?
            "homonym replaced by #{format_name(taxon.homonym_replaced_by)}"
          elsif taxon.unidentifiable?
            'unidentifiable'
          elsif taxon.unresolved_homonym?
            "unresolved junior homonym"
          elsif taxon.protonym.nomen_nudum?
            'nomen nudum'
          elsif taxon.valid_status?
            "valid"
          elsif taxon.synonym?
            "synonym of #{format_name(taxon.current_taxon)}"
          else
            taxon.status
          end
        end

        def format_protonym taxon
          reference = taxon.authorship_reference

          string = +''
          string << reference.decorate.plain_text.to_s
          string << "   #{reference.id}"
          string
        end

        def format_type_localities taxon
          string = +''
          if taxon.protonym.locality
            string << AddPeriodIfNecessary[taxon.protonym.locality]
          end
          if taxon.protonym.bioregion
            string << ' ' << taxon.protonym.bioregion
            string << '.'
          end
          string
        end
    end
  end
end
