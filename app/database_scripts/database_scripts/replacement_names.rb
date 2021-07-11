# frozen_string_literal: true

module DatabaseScripts
  class ReplacementNames < DatabaseScript
    def results
      Taxon.replaced_homonyms.
        includes(
          protonym: [:name, { taxa: :name }],
          homonym_replaced_by: [{ protonym: [:name, { taxa: :name }] }]
        )
    end

    def render
      as_table do |t|
        t.header 'Replaced protonym (1)', 'Replaced by protonym (2)',
          'Forms, locality, bio region (1)', 'Forms, locality, bio region (2)',
          'Type name of replaced protonym (1)', 'Type name of replaced by protonym (2)',
          'Taxa of replaced protonym (1)', 'Taxa of replaced by protonym (2)'
        t.rows do |taxon|
          replaced_protonym = taxon.protonym
          replaced_by_protonym = taxon.homonym_replaced_by.protonym

          [
            protonym_links_with_author_citations(replaced_protonym),
            protonym_links_with_author_citations(replaced_by_protonym),

            replaced_protonym_synopsis(replaced_protonym),
            replaced_by_protonym_synopsis(replaced_protonym, replaced_by_protonym),

            (taxon_link(replaced_protonym.type_name.taxon) if replaced_protonym.type_name),
            (taxon_link(replaced_by_protonym.type_name.taxon) if replaced_by_protonym.type_name),

            taxon_links(replaced_protonym.taxa),
            taxon_links(replaced_by_protonym.taxa)
          ]
        end
      end
    end

    private

      def replaced_protonym_synopsis protonym
        return unless protonym.species_group_name?
        "#{protonym.forms || '[blank]'}<br>#{protonym.locality || '[blank]'}<br>#{protonym.biogeographic_region || '[blank]'}"
      end

      def replaced_by_protonym_synopsis r_pro, rbp_pro
        return unless r_pro.species_group_name?

        forms = color_span(
          rbp_pro.forms || '[blank]',
          rbp_pro.forms.in?([nil, r_pro.forms]) ? 'bold-notice' : 'purple-notice'
        )

        locality = color_span(
          rbp_pro.locality || '[blank]',
          rbp_pro.locality.in?([nil, r_pro.locality]) ? 'bold-notice' : 'bold-warning'
        )

        bio_region = color_span(
          rbp_pro.biogeographic_region || '[blank]',
          rbp_pro.biogeographic_region.in?([nil, r_pro.biogeographic_region]) ? 'bold-notice' : 'bold-warning'
        )

        "#{forms}<br>#{locality}<br>#{bio_region}"
      end
  end
end

__END__

section: research
tags: [replacement-names, list, slow-render]

description: >
  Via `taxa.homonym_replaced_by_id`.

related_scripts:
  - ReplacementNames
