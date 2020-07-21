# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies < DatabaseScript
    LIMIT = 75

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
        t.header 'Protonym (and cleaned name)', 'Author',
          'Protonym taxa', 'Taxa with same name',
          'Quick-add button', 'Quick-add attributes'
        t.rows do |protonym|
          quick_adder = QuickAdd::FromExistingProtonymFactory.create_quick_adder(protonym)
          cleaned_name = protonym.name.cleaned_name

          [
            protonym.decorate.link_to_protonym + "<br>#{cleaned_name}".html_safe,
            protonym.author_citation,

            taxon_links_with_author_citations(protonym.taxa),
            taxon_links_with_author_citations(Taxon.where(name_cache: cleaned_name)),

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
tags: [slow, has-quick-fix]

description: >
  Species only in this batch, and only less advanced cases.


  "Without a taxon with same cleaned name" kind of means "without and original combination",
  but there is already a similar script for that.


  Script column | Description

  --- | ---

  **Protonym taxa** | Lists all taxon records currently belonging to the protonym.
  The suggested `current_taxon` from **Quick-add attributes** will be one of these (or blank/???).

  **Taxa with same name** | Contains all taxon records with the same cleaned name.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies
