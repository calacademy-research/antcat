class AdvancedSearchPresenter
  class Text < AdvancedSearchPresenter
    def format taxon
      string = format_name(taxon).html_safe
      string << ' '
      string << convert_to_text(format_status_reference(taxon).html_safe)
      type_localities = format_type_localities(taxon)
      string << convert_to_text(' ' + type_localities) if type_localities.present?
      string << "\n"
      string << convert_to_text(format_protonym(taxon))
      string << "\n\n"
    end

    private

      def format_name taxon
        taxon.name_cache
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
          string << add_period_if_necessary(taxon.protonym.locality)
        end
        if taxon.protonym.biogeographic_region
          string << ' ' << taxon.protonym.biogeographic_region
          string = add_period_if_necessary string
        end
        string
      end

      def italicize string
        string
      end

      def convert_to_text string
        unitalicize string.html_safe
      end
  end
end
