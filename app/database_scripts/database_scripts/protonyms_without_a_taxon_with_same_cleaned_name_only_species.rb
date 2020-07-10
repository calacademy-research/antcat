# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies < DatabaseScript
    LIMIT = 100

    def results
      Protonym.
        joins(:name).where("(LENGTH(names.cleaned_name) - LENGTH(REPLACE(names.cleaned_name, ' ', '')) = 1)").
        where.not(id: protonyms_with_a_taxon_with_same_cleaned_name.select(:id)).
        joins(taxa: :name).
        where(taxa: { type: Rank::SPECIES }).
        where('names_taxa.epithet = names.epithet').
        distinct.limit(LIMIT)
    end

    def statistics
      <<~STR.html_safe
        Results: #{results.limit(nil).count} (showing first #{LIMIT})<br>
      STR
    end

    def render
      as_table do |t|
        t.header 'Protonym (and cleaned name)', 'Protonym taxa', 'Quick-add button', 'Quick-add attributes'
        t.rows do |protonym|
          quick_adder = QuickAdd::FromExistingProtonymFactory.create_quick_adder(protonym)

          [
            protonym.decorate.link_to_protonym + "<br>#{protonym.name.cleaned_name}".html_safe,
            taxa_list(protonym.taxa),

            (new_taxon_link(quick_adder) if quick_adder.can_add?),
            quick_adder.synopsis
          ]
        end
      end
    end

    private

      def protonyms_with_a_taxon_with_same_cleaned_name
        Protonym.joins(:name, [taxa: :name]).
          group(:protonym_id).where("names.cleaned_name = names_taxa.cleaned_name")
      end

      def new_taxon_link quick_adder
        label = "Add #{quick_adder.rank}"
        link_to label, new_taxa_path(quick_adder.taxon_form_params), class: "btn-tiny btn-normal"
      end
  end
end

__END__

title: Protonyms without a taxon with same cleaned name (only species)

section: main
category: Catalog
tags: [slow, new!, has-quick-fix]

description: >
  Species only in this batch, and only less advanced cases.


  "without a taxon with same cleaned name" kind of means "without and original combination",
  but there is already a similar script for that.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies
