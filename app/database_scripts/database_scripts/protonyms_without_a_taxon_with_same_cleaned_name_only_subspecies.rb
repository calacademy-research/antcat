# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies < DatabaseScript
    PER_PAGE = 200

    def paginated_results page:
      @_paginated_results ||= results.paginate(page: page, per_page: PER_PAGE)
    end

    def results
      Protonym.
        joins(:name).where("(LENGTH(names.cleaned_name) - LENGTH(REPLACE(names.cleaned_name, ' ', '')) = 2)").
        where.not(id: protonyms_with_a_taxon_with_same_cleaned_name.select(:protonym_id)).
        joins(taxa: :name).
        where(taxa: { type: Rank::SPECIES }).
        where('names_taxa.epithet = names.epithet').
        distinct
    end

    def render results_to_render: results
      as_table do |t|
        t.header 'Protonym (and cleaned name)', 'Author',
          'Original combination',
          'Protonym taxa', 'Taxa with same name',
          'Quick-add button', 'Warnings', 'Quick-add attributes'
        t.rows(results_to_render) do |protonym|
          quick_adder = QuickAdd::FromExistingProtonymFactory.create_quick_adder(protonym)
          cleaned_name = protonym.name.cleaned_name

          original_combination = protonym.original_combination

          [
            protonym.decorate.link_to_protonym + "<br>#{cleaned_name}".html_safe,
            protonym.author_citation,

            (original_combination ? taxon_link(original_combination) : 'No original combination'),

            taxon_links_with_author_citations(protonym.taxa),
            taxon_links_with_author_citations(Taxon.where(name_cache: cleaned_name)),

            (new_taxon_link(quick_adder) if quick_adder.can_add?),
            (bold_warning('Protonym already has an original combination') if quick_adder.can_add? && original_combination),
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
        link_to label, new_taxon_path(quick_adder.taxon_form_params), class: "btn-tiny btn-normal"
      end
  end
end

__END__

title: Protonyms without a taxon with same cleaned name (only subspecies)

section: research
tags: [protonyms, names, slow, has-quick-fix]

description: >
  Subspecies only in this batch, and only less advanced cases.


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

