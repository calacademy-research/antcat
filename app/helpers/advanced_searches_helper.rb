module AdvancedSearchesHelper
  PER_PAGE_OPTIONS = [30, 100, 500, 1000]

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
