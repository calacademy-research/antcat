module NavigationHelpers
  def path_to(page_name)
    case page_name
    when /the main page/
      root_path
    when /the references page/
      references_path
    when /the page for that reference/
      reference_path(@reference || Reference.first)    
    when /the edit user page/
      '/users/edit'
    when /the duplicate reference list/
      duplicate_references_path
    when /the "Edit journals" page/
      journals_path
    when /the Taxatry index/
      index_taxatry_path
    when /the Taxatry browser/
      browser_taxatry_path
    when /the forgot password page/
      '/users/password/new'
    when /the login page/
      '/users/sign_in'
    else
      raise "#{page_name} not found"
    end
  end
end

World(NavigationHelpers)
