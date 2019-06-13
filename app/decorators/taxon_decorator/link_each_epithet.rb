class TaxonDecorator::LinkEachEpithet
  include Service
  include Formatters::ItalicsHelper

  def initialize taxon
    @taxon = taxon
  end

  # This links the different parts of the binomial name. Only applicable to
  # species and below, since higher ranks consists of a single word.
  def call
    return @taxon.link_to_taxon unless @taxon.is_a? SpeciesGroupTaxon

    if @taxon.is_a? Species
      return genus_link << header_link(@taxon, @taxon.name.epithet_html.html_safe)
    end

    species = @taxon.species

    string = genus_link
    string << if species
                header_link(species, species.name.epithet_html.html_safe)
              else
                no_species_warning
              end
    string << ' '.html_safe
    string << header_link(@taxon, italicize(@taxon.name.subspecies_epithets))
    string
  end

  private

    def genus_link
      # Link name of the genus, but add dagger per to taxon's fossil status.
      label = @taxon.genus.name.name_with_fossil_html @taxon.fossil?
      @taxon.genus.decorate.link_to_taxon_with_label(label.html_safe) << " "
    end

    def header_link taxon, label
      taxon.decorate.link_to_taxon_with_label label
    end

    # TODO: remove once http://localhost:3000/database_scripts/subspecies_without_species has been cleared.
    def no_species_warning
      '<span class="bold-warning">[species missing]</span>'.html_safe
    end
end
