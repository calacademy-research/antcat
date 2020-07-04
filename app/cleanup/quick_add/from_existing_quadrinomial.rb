# frozen_string_literal: true

# TODO: Temporary code for `DatabaseScripts::QuadrinomialsToBeConverted`.
module QuickAdd
  class FromExistingQuadrinomial
    include Service

    def initialize quadrinomial
      @quadrinomial = quadrinomial
    end

    def taxon_form_params
      {
        rank_to_create: rank,
        parent_id: parent.id,
        taxon_name_string: subspecies_name_object.name,
        edit_summary: "[semi-automatic] Quick-add missing species for quadrinomial"
      }
    end

    def rank
      Rank::SUBSPECIES
    end

    def synopsis
      <<~SYNOPSIS
        <b>Name</b>: #{subspecies_name_object.name_html}<br>
        <b>Rank</b>: #{rank}<br>
        <b>Parent</b>: [#{parent.type}] #{CatalogFormatter.link_to_taxon(parent)}<br>
        <br>

        <b>Quadrinomial epithet</b>: #{quadrinomial_epithet}<br>
        <b>Existing subspecies epithets</b>: #{highlight_first_letters_of_epithets_in_existing_epithets.presence || '-'}<br>
      SYNOPSIS
    end

    private

      attr_reader :quadrinomial

      def parent
        quadrinomial.species
      end

      def subspecies_name_object
        @_subspecies_name_object ||= SpeciesName.new(name: subspecies_name_string)
      end

      def subspecies_name_string
        @_subspecies_name_string ||= quadrinomial.name.name.split[0..2].join(' ')
      end

      def quadrinomial_epithet
        @_quadrinomial_epithet ||= quadrinomial.name.name.split.last
      end

      def subspecies_epithet
        @_subspecies_epithet ||= subspecies_name_string.split.last
      end

      def existing_subspecies_epithets
        parent.subspecies.
          joins(:name).where("(LENGTH(names.name) - LENGTH(REPLACE(names.name, ' ', '')) < 3) ").
          pluck(:epithet).sort
      end

      def highlight_first_letters_of_epithets_in_existing_epithets
        quadrinomial_epithet_first_letters = quadrinomial_epithet[0..2]
        subspecies_epithet_first_letters = subspecies_epithet[0..2]

        existing_subspecies_epithets.map do |epithet|
          if epithet.starts_with?(quadrinomial_epithet_first_letters)
            epithet.sub(
              quadrinomial_epithet_first_letters,
              "<span class='bold-warning'>[similar to infrasubspecies epithet] #{quadrinomial_epithet_first_letters}</span>"
            )
          elsif epithet.starts_with?(subspecies_epithet_first_letters)
            epithet.sub(
              subspecies_epithet_first_letters,
              "<span class='bold-notice'>[similar to subspecies epithet] #{subspecies_epithet_first_letters}</span>"
            )
          else
            epithet
          end
        end.join(', ')
      end
  end
end
