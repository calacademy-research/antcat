# frozen_string_literal: true

module DatabaseScripts
  class GenusGroupNamesWithoutATypeName < DatabaseScript
    LIMIT = 100

    def results
      Taxon.where(type: Rank::GENUS_GROUP_NAMES).
        includes(:name, protonym: :name).
        left_outer_joins(protonym: :type_name).
        where(type_names: { id: nil }).
        limit(LIMIT)
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Status', 'Protonym', 'Replacement name for', 'Inherited TypeName Taxon(s)'
        t.rows do |taxon|
          protonym = taxon.protonym

          replacement_name_for = Taxon.where(homonym_replaced_by: taxon)
          inherited_type_name_taxa = replacement_name_for.map { |t2| t2.protonym.type_name&.taxon }

          [
            taxon_link(taxon),
            taxon.status,
            protonym.decorate.link_to_protonym,
            taxon_links_with_author_citations(replacement_name_for),
            taxon_links_with_author_citations(inherited_type_name_taxa)
          ]
        end
      end
    end
  end
end

__END__

title: Genus-group names without a type name

section: research
category: Types
tags: [slow, new!]

issue_description:

description: >

related_scripts:
  - GenusGroupNamesWithoutATypeName
  - TypeNamesOfReplacementNamesForGenusGroupNames
