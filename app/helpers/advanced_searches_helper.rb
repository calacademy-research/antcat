module AdvancedSearchesHelper
  PER_PAGE_OPTIONS = [30, 100, 500, 1000]

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
      options_for_select(Taxon::BIOGEOGRAPHIC_REGIONS, value)
  end

  def search_status_options_for_select value = "Any"
    extra_options = [["Any", ""]]
    options_for_select(extra_options, value) << options_for_select(Status::STATUSES, value)
  end

  def any_yes_no_options_for_select value = "Any"
    options = [
      ["Any", ""],
      ["Yes", "true"],
      ["No", "false"]
    ]

    options_for_select(options, value)
  end

  def per_page_select per_page
    select_tag :per_page, options_for_select(per_page_options, (per_page || 30))
  end

  private

    def per_page_options
      PER_PAGE_OPTIONS.map { |number| ["Show #{number} results per page", number] }
    end
end
