# frozen_string_literal: true

module DatabaseScripts
  class TypeTaxaWithIssues < DatabaseScript
    def results
      Taxon.valid.where.not(type_taxon_id: nil).includes(:type_taxon)
    end

    def statistics
      # No-op because results are filtered in `#render`.
    end

    def render
      as_table do |t|
        t.header 'Taxon', 'Rank', 'Type taxon', 'TT rank', 'TT status', 'Type taxon now', 'TTN rank',
          'TTN status', 'Issue', 'Suggested script action'
        t.rows do |taxon|
          type_taxon = taxon.type_taxon
          type_taxon_now = type_taxon.now.__getobj__
          issue, suggested_script_action = check_issue(taxon, type_taxon, type_taxon_now)
          next unless issue

          [
            taxon_link(taxon),
            taxon.rank,
            taxon_link(type_taxon),
            type_taxon.rank,
            type_taxon.status,
            taxon_link(type_taxon_now),
            type_taxon_now.rank,
            type_taxon_now.status,
            issue,
            suggested_script_action
          ]
        end
      end
    end

    private

      def check_issue taxon, type_taxon, type_taxon_now
        ancestors = Taxa::TaxonAndAncestors[type_taxon_now]

        same_ranked_ancestor = ancestors.find { |ancestor| ancestor.type == taxon.type }

        unless same_ranked_ancestor
          if taxon.is_a?(Subgenus) && type_taxon_now.genus == taxon.genus && type_taxon_now.subgenus.nil?
            suggested_script_action = +"Set the subgenus of #{type_taxon.name.name_html} to #{taxon.name.name_html}"

            if type_taxon != type_taxon_now && type_taxon_now.is_a?(Species)
              suggested_script_action << "; <b>and set the subgenus of #{type_taxon_now.name.name_html} to #{taxon.name.name_html}<b>"
            end

            return [
              "<span style='color: darkblue'>Taxon is not an ancestor of TTN (but it's genus matches taxon's genus)</span>",
              suggested_script_action
            ]
          else
            return ["<span style='color: red'><b>Taxon is not an ancestor of TTN</b></span>"]
          end
        end

        unless same_ranked_ancestor == taxon
          message = "<b>TTN's #{taxon.rank} should be #{taxon.name.name_html} but is is #{same_ranked_ancestor.name.name_html}</b>"
          return ["<span style='color: purple'>#{message}</span>"]
        end

        false
      end
  end
end

__END__

section: main
category: Catalog
tags: [slow]

description: >
  This script checks all valid taxa that have a type taxon.


  See "Issue" column for what's wrong.

  "Taxon is not an ancestor of TTN" does not work with homonyms, so please ignore them.


  "Taxon is not an ancestor of TTN (but it's genus matches taxon's genus)" can be fixed by script.


  This script has some overlaps with %dbscript:SubgeneraWithSameNameAsAGenus

related_scripts:
  - TypeTaxaAssignedToMoreThanOneTaxon
  - TypeTaxaWithIssues
