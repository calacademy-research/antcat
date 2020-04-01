# frozen_string_literal: false

module Exporters
  module Taxa
    class TaxaAsTxt
      include Service

      attr_private_initialize :taxa

      def call
        taxa.reduce('') do |content, taxon|
          content << format_taxon(taxon)
        end
      end

      private

        def format_taxon taxon
          string = format_name(taxon).html_safe
          string << ' '
          string << convert_to_text(format_status(taxon).html_safe)
          type_localities = format_type_localities(taxon)
          string << convert_to_text(' ' + type_localities) if type_localities.present?
          string << "\n"
          string << convert_to_text(format_protonym(taxon))
          string << "\n\n"
        end

        def format_name taxon
          taxon.name_cache
        end

        # TODO: DRY w.r.t. `ExpandedStatus`.
        def format_status taxon
          labels = []
          labels << "incertae sedis in #{taxon.incertae_sedis_in}" if taxon.incertae_sedis_in
          if taxon.homonym? && taxon.homonym_replaced_by
            labels << "homonym replaced by #{format_name(taxon.homonym_replaced_by)}"
          elsif taxon.unidentifiable?
            labels << 'unidentifiable'
          elsif taxon.unresolved_homonym?
            labels << "unresolved junior homonym"
          elsif taxon.nomen_nudum?
            labels << 'nomen nudum'
          elsif taxon.valid_taxon?
            labels << "valid"
          elsif taxon.synonym?
            labels << "synonym of #{format_name(taxon.current_valid_taxon)}"
          elsif taxon.invalid?
            labels << taxon.status
          end
          labels << 'ichnotaxon' if taxon.ichnotaxon?
          labels.join(', ').html_safe
        end

        def format_protonym taxon
          reference = taxon.authorship_reference

          string = ''.html_safe
          string << reference.decorate.plain_text
          string << " DOI: " << reference.doi if reference.doi?
          string << "   #{reference.id}"
          string
        end

        def format_type_localities taxon
          string = ''
          if taxon.protonym.locality
            string << AddPeriodIfNecessary[taxon.protonym.locality]
          end
          if taxon.protonym.biogeographic_region
            string << ' ' << taxon.protonym.biogeographic_region
            string << '.'
          end
          string
        end

        def convert_to_text string
          Unitalicize[string.html_safe]
        end
    end
  end
end
