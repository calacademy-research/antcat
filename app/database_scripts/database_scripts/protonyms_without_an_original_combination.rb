# frozen_string_literal: true

module DatabaseScripts
  class ProtonymsWithoutAnOriginalCombination < DatabaseScript
    def results
      protonyms.includes(:name)
    end

    def render
      as_table do |t|
        t.header 'Protonym', 'Taxa'
        t.rows do |protonym|
          [
            protonym.decorate.link_to_protonym,
            taxa_quick_fix_links(protonym)
          ]
        end

        t.info "Stats: #{quick_fix_stats}"
      end
    end

    private

      def protonyms
        records = Protonym.species_group_names.
          joins("LEFT JOIN taxa ON taxa.protonym_id = protonyms.id AND taxa.original_combination = TRUE").
          where(taxa: { id: nil }).group('protonyms.id').distinct
        Protonym.where(id: records.select(:id))
      end

      def quick_fix_stats
        @_quick_fix_stats ||= Hash.new(0)
      end

      def taxa_quick_fix_links protonym
        protonym.taxa.map do |taxon|
          <<~STR.squish
            <i>#{protonym.name.cleaned_name}</i> &nbsp;&nbsp;<small>protonym cleaned name</small><br>
            <i>#{taxon.name.cleaned_name}</i> &nbsp;&nbsp;<small>taxon cleaned name</small><br>

            #{CatalogFormatter.link_to_taxon(taxon)}<br>

            #{quick_fix_link(taxon, protonym)}<br><br>
          STR
        end.join('<br>')
      end

      def quick_fix_link taxon, protonym
        return cannot_quick_fix('incompatible ranks [case B]') unless taxon.name.class == protonym.name.class

        # Ignore all such cases for now, both species and subspecies.
        if non_identical_genus_epithet?(taxon, protonym)
          return cannot_quick_fix 'non-identical genus epithets [case C]'
        end

        if taxon.is_a?(Species) && very_different_species_epithet?(taxon, protonym)
          return cannot_quick_fix 'very different species epithets of species [case D]'
        end

        if taxon.is_a?(Subspecies)
          if very_different_subspecies_epithet?(taxon, protonym)
            return cannot_quick_fix 'very different subspecies epithets of subspecies [case E]'
          end

          if very_different_species_epithet?(taxon, protonym)
            return cannot_quick_fix 'very different species epithets of subspecies [case F]'
          end

          # Require species epithets of subspecies to be identical for now.
          if non_identical_species_epithet?(taxon, protonym)
            return cannot_quick_fix_now 'non-identical species epithets of subspecies [case G]'
          end
        end

        quick_fix_stats['can be quick-fixed [case A]'] += 1

        link_to '^-- Flag as Original combination!',
          flag_as_original_combination_quick_and_dirty_fix_path(taxon_id: taxon.id),
          method: :post, remote: true, class: 'btn-default btn-tiny'
      end

      def cannot_quick_fix reason
        quick_fix_stats[reason] += 1
        bold_warning "^-- Cannot quick-fix because: #{reason}"
      end

      def cannot_quick_fix_now reason
        quick_fix_stats[reason] += 1
        purple_notice "^-- Cannot quick-fix for now because: #{reason}"
      end

      def non_identical_genus_epithet? taxon, protonym
        taxon.name.genus_epithet != protonym.name.genus_epithet
      end

      def non_identical_species_epithet? taxon, protonym
        taxon.name.species_epithet != protonym.name.species_epithet
      end

      def very_different_species_epithet? taxon, protonym
        taxon.name.species_epithet[0...3] != protonym.name.species_epithet[0...3]
      end

      def very_different_subspecies_epithet? taxon, protonym
        taxon.name.subspecies_epithet[0...3] != protonym.name.subspecies_epithet[0...3]
      end
  end
end

__END__

section: research
tags: [protonyms, combinations, original-combinations, has-quick-fix]

description: >
  "Original combination" as in a `Taxon` flagged as `original_combination`.

related_scripts:
  - NonOriginalCombinationsWithSameNameAsItsProtonym
  - ProtonymsWithMoreThanOneOriginalCombination
  - ProtonymsWithoutAnOriginalCombination
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySpecies
  - ProtonymsWithoutATaxonWithSameCleanedNameOnlySubspecies
