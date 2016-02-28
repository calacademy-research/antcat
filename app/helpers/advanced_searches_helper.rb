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
end
