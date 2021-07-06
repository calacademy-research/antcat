# frozen_string_literal: true

module DatabaseScripts
  class TypesOfGenusGroupNames < DatabaseScript
    def empty_status
      DatabaseScripts::EmptyStatus::NOT_APPLICABLE
    end

    def statistics
    end

    def results
      Taxon.extant.genus_group_names
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Author citation', 'Status', 'Rank', 'Fossil',
          'now_taxon', 'NT status', 'NT rank', 'NT subfamily',
          'protonym.type_name.taxon', 'PTNT author citation', 'PTNT status', 'PTNT rank',
          'now_taxon of PTNT if different'
        t.rows do |taxon|
          now_taxon = taxon.now_taxon

          [
            taxon_link(taxon),
            taxon.author_citation,
            taxon.status,
            taxon.type,
            taxon.protonym.fossil,

            taxon_link(now_taxon),
            now_taxon.status,
            now_taxon.type,
            now_taxon.subfamily&.name_cache
          ] + type_name_columns(taxon)
        end
      end
    end

    private

      def type_name_columns taxon
        return [] unless (type_name = taxon.protonym.type_name)

        type_name_taxon = type_name.taxon
        type_name_taxon_now = type_name_taxon.now_taxon

        [
          taxon_link(type_name_taxon),
          type_name_taxon.author_citation,
          type_name_taxon.status,
          type_name_taxon.type,
          (taxon_link(type_name_taxon_now) unless type_name_taxon == type_name_taxon_now)
        ]
      end
  end
end

__END__

title: Types of genus-group names

section: list
tags: [types, very-slow]

description: >

related_scripts:
  - TypesOfGenusGroupNames
