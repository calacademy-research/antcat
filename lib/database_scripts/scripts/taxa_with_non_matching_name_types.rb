class DatabaseScripts::Scripts::TaxaWithNonMatchingNameTypes
  include DatabaseScripts::DatabaseScript

  def subfamily_results
    Subfamily.joins(:name).where("names.type != 'SubfamilyName'")
  end

  def tribe_results
    Tribe.joins(:name).where("names.type != 'TribeName'")
  end

  def genus_results
    Genus.joins(:name).where("names.type != 'GenusName'")
  end

  def subgenus_results
    Subgenus.joins(:name).where("names.type != 'SubgenusName'")
  end

  def species_results
    Species.joins(:name).where("names.type != 'SpeciesName'")
  end

  def subspecies_results
    Subspecies.joins(:name).where("names.type != 'SubspeciesName'")
  end

  def render
    format_table_for(:subfamily, subfamily_results) <<
      format_table_for(:tribe, tribe_results) <<
      format_table_for(:genus, genus_results) <<
      format_table_for(:subgenus, subgenus_results) <<
      "Showing the first 20 of #{species_results.count} species results." <<
      format_table_for(:species, species_results.limit(20)) <<
      format_table_for(:subspecies, subspecies_results)
  end

  private
    def format_table_for rank, rank_results
      as_table do
        header rank, :status, :name_type

        rows(rank_results) do |taxon|
          [ markdown_taxon_link(taxon), taxon.status, taxon.name.type ]
        end
      end
    end
end

__END__
description: >
  Where "name type" is the type/class a taxon's name is stored in the database
  as -- this is unrelated to "type name" or any other "type" as used in
  taxonomy. "Non-matching" means "not corresponing to the taxon's type" --
  it may be the other way around, that the name type is correct but the
  taxon's type is not.

topic_areas: [catalog]
