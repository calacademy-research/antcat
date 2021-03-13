# frozen_string_literal: true

module DatabaseScripts
  class PeculiarAndInterestingCases < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def results
      []
    end

    def render
      as_table do |t|
        t.caption "Replacement names used for more than one taxon"
        t.info Markdowns::ParseAntcatTags['See also %dbscript:ReplacementNamesUsedForMoreThanOneTaxon']

        t.header 'Taxon', 'Replacement name for'
        t.rows(replacement_names_for_more_than_one_taxon) do |taxon|
          [
            taxon_link(taxon),
            taxon_links_with_author_citations(taxon.replacement_name_for)
          ]
        end
      end <<
        as_table do |t|
          t.caption "Protonyms with weird type name ranks"

          t.header 'Protonym', 'Protonym rank', 'Case', 'TypeName.taxon', 'TN.t rank'
          t.rows(genus_protonyms_with_non_species_type_names) do |protonym|
            type_name_taxon = protonym.type_name.taxon

            [
              protonym_link_with_terminal_taxa(protonym),
              protonym.rank_from_name,
              "#{protonym.rank_from_name} protonym with a type-#{type_name_taxon.type}",
              taxon_link(type_name_taxon),
              type_name_taxon.type
            ]
          end
        end
    end

    private

      def replacement_names_for_more_than_one_taxon
        Taxon.joins(:replacement_name_for).group(:id).having('COUNT(replacement_name_fors_taxa.id) > 1')
      end

      def genus_protonyms_with_non_species_type_names
        Protonym.genus_group_names.joins(type_name: :taxon).where.not(taxa: { type: Rank::SPECIES })
      end
  end
end

__END__

section: research
category: Grab bag
tags: [new!]

description: >

related_scripts:
  - PeculiarAndInterestingCases
