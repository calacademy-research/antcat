module CatalogSearchHelper
  def search_type_selector search_type
    search_type ||= "beginning_with"
    options = [['Matching', 'matching'],
               ['Beginning with', 'beginning_with'],
               ['Containing', 'containing']]

    select_tag :search_type, options_for_select(options, search_type)
  end
end
