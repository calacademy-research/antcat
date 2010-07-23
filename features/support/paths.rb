module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /the main page/
      '/references'
    when /the page for that reference/
      reference_path(@reference || Reference.first)    
    when /the edit page for that reference/
      edit_reference_path(@reference || Reference.first)    
    end
  end
end

World(NavigationHelpers)
