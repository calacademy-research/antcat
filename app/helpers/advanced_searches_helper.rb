module AdvancedSearchesHelper
  include Formatters::AdvancedSearchHtmlFormatter

  def rank_options_for_select value = 'All'
    options = { "All"         => "All",
                "Subfamilies" => "Subfamily",
                "Tribes"      => "Tribe",
                "Genera"      => "Genus",
                "Subgenera"   => "Subgenus",
                "Species"     => "Species",
                "Subspecies"  => "Subspecies" }

    options_for_select options, value
  end

  def search_biogeographic_region_options_for_select value = "All"
    extra_options = [["Any", ""], ["None", "None"]]

    options_for_select(extra_options, value) <<
      options_for_select(BiogeographicRegion::REGIONS, value)
  end
end
