module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /the main page/
      '/'
    when /the page for that reference/
      reference_path(@reference || Reference.first)    
    when /the edit user page/
      '/users/edit'
    when /the species list/
      '/species'
    when /the duplicate reference list/
      '/duplicate_references'
    when /the "Edit journals" page/
      '/journals'
    when /the Taxatry/
      '/taxatry'
    when /the forgot password page/
      '/users/password/new'
    end
  end
end

World(NavigationHelpers)
